// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// We first import some OpenZeppelin contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract Base64.sol.
import { Base64 } from "./libraries/Base64.sol";

// We inherit the ERC721URIStorage we just imported above. This gives us access to its methods
contract MyEpicNFT is ERC721URIStorage {
    // OpenZeppelin helps us keep track of tokenIds
    using Counters for Counters.Counter;
    // _tokenIds is a state variable that's stored on the contract.
    Counters.Counter private _tokenIds;

    // This is our SVG code. 
    // So, we make a baseSvg variable here that all our NFTs can use.
    //string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // We split the SVG at the part where it asks for the background color.
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever! 
    string[] firstWords = ["Three", "No", "Mini", "Giant", "Hey", "Confused", "Pretty", "Sorry", "Super", "Extra", "Ultra", "Funny","Little", "Go", "Complicated", "Tickly", "Tricky", "Bumpy"];
    string[] secondWords = ["Silly", "Fishy", "Gloomy", "Fuzzy", "Hazy", "Sleepy", "Grumpy", "Shiny", "Fluffy", "Sensitive", "Spongy", "Cuddly", "Jumpy", "Wiggly", "Sassy", "Angry", "Lazy", "Happy", "Mighty", "Goofy"];
    string[] thirdWords = ["Fish", "Goose", "Donkey", "Puppy", "Giraffe", "Rhino", "Spider", "Cow", "Mouse", "Duck", "Bunny", "Frog", "Bear", "Panda", "Fox", "Wolf", "Woodpecker", "Bat"];

    // Get fancy with it! Declare a bunch of colors.
    string[] colors = ["orange", "#08C2A8", "magenta", "cyan", "purple", "brown"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and its symbol
    constructor() ERC721 ("SquareNFT", "SQUARE"){
        console.log("NFT contract 101!");
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // I seed the random generator. More on this in the lesson. 
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    // Same old stuff, pick a random color.
    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }
    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getCurrentNFTCount() public view returns (uint256) {
        // Get the current tokenId, this starts at 0.
        return _tokenIds.current();
    }
    
    // Our users will hit makeAnEpicNFT function to get their NFT
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // Add the random color in.
        string memory randomColor = pickRandomColor(newItemId);
        string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

        // I concatenate it all together, and then close the <text> and <svg> tags.
        // string memory finalSvg = string(abi.encodePacked(baseSvg, first, second, third, "</text></svg>"));
        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // Actually  mint the NFT to the sender using msg.sender.
        // msg.sender is provided by solidity. It gives the public address of the person calling the contract
        // You cannot call a contract anonymously. You need to connect your wallet which authenticates you.
        _safeMint(msg.sender, newItemId);

        // Set NFT's data
        //"https://jsonkeeper.com/b/V4WL"
        _setTokenURI(newItemId, finalTokenUri); 

        // Increment the counter for when the next NFT is minted.
        // This is what makes NFTs non fungible 
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}