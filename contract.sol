//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract BPHCSocial is ERC721URIStorage {
    uint256  tokenCount;
    uint256 public postCount;
    mapping(uint256 => Post) posts;
    mapping (uint256 => string[2])  accounts;
    mapping(address => uint256) profiles;
    
    struct Post {
        uint256 id;
        string content;
        uint256 likes;
        address payable author;
        string profile;
        string image;
    }

    struct ProfileRecieve {
        uint256 id;
        string name;
    }
    
    event PostCreated(
        uint256 id,
        string content,
        uint256 likes,
        address payable author,
        string profile,
        string image
    );

    event PostLiked(
        uint256 id,
        string content,
        uint256 likes,
        address payable author
    );

    constructor() ERC721("BPHCSocial", "DAPP") {}

    function CreateProfile(string memory _name,string memory _image) external returns (uint256) {
        require(bytes(_name).length > 0);
        tokenCount++;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _name);
        setProfile(tokenCount);
        accounts[tokenCount][0] = _name;
        accounts[tokenCount][1] = _image;
        return (tokenCount);
    }

    function setProfile(uint256 _id) public {
        require(ownerOf(_id) == msg.sender);
        profiles[msg.sender] = _id;
    }

    function uploadPost(string memory _postcontent,string memory _image) external {
        require(bytes(_postcontent).length > 0||bytes(_image).length > 0);
        postCount++;
        if (bytes(_image).length > 0)
            {posts[postCount] = Post(postCount, _postcontent, 0, payable(msg.sender),accounts[profiles[msg.sender]][0],_image);
            emit PostCreated(postCount, _postcontent, 0, payable(msg.sender),accounts[profiles[msg.sender]][0],_image);
            }
        else{posts[postCount] = Post(postCount, _postcontent, 0, payable(msg.sender),accounts[profiles[msg.sender]][0],"None");
            emit PostCreated(postCount, _postcontent, 0, payable(msg.sender),accounts[profiles[msg.sender]][0],"None");
        }
    }

    function LikePost(uint256 _id) external payable {
        require(_id > 0 && _id <= postCount);
        Post memory _post = posts[_id];
        require(_post.author != msg.sender);
        _post.author.transfer(msg.value);
        _post.likes += 1;
        posts[_id] = _post;
        emit PostLiked(_id, _post.content, _post.likes, _post.author);
    }

    function getAllPosts() external view returns (Post[] memory _posts) {
        _posts = new Post[](postCount);
        for (uint256 i = postCount; i>0; i--) {
            _posts[postCount-i] = posts[i];
        }
    }

    function getMyProfiles() external view returns (ProfileRecieve[] memory _ids) {
        _ids = new ProfileRecieve[](balanceOf(msg.sender));
        uint256 currentIndex;
        uint256 _tokenCount = tokenCount;
        for (uint256 i = 0; i < _tokenCount; i++) {
            if (ownerOf(i + 1) == msg.sender) {
                _ids[currentIndex].id = i + 1;
                _ids[currentIndex].name = accounts[i+1][0];
                currentIndex++;
            }
        }
    }
}
