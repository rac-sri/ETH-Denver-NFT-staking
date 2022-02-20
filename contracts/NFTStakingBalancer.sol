pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interface/IBalancerPool.sol";

contract NFTStaking is ERC721, AccessControl {
    struct Position {
        uint256[] tokens;
        uint256 lockTimestamp;
    }
    mapping(address => mapping(address => Position)) positionsToUser;

    constructor() ERC721("NSB", "NFTStaking") {}

    function addERC20Token(IERC20 addr, uint256 amount) public {
        // approval is required pre this step
        // vulnerable approach, since addr.transferFrom can be malicous and no token actually gets deposited.
        require(
            addr.transferFrom(msg.sender, address(this), amount),
            "Not applicable"
        );
    }

    function mintNft(address _destination, uint256 tokenId) internal {
        _mint(_destination, tokenId);
    }

    function depositToPoolAndLock(
        uint256 poolAmountOut,
        uint256[] calldata maxAmountIn,
        BalancerPool poolAddress
    ) public {
        poolAddress.joinPool(poolAmountOut, maxAmountIn);
        Position memory position = positionsToUser[msg.sender][
            address(poolAddress)
        ];

        if (position.tokens.length == 0) {
            position = Position(maxAmountIn, block.timestamp);
            positionsToUser[msg.sender][address(poolAddress)] = position;
        } else {
            uint256 tokens = poolAddress.getNumTokens();

            for (uint256 i = 0; i < tokens; i++) {
                position.tokens[i] += maxAmountIn[i];
            }
        }
    }

    function withdrawFromPool(
        uint256 poolAmountIn,
        uint256[] calldata minAmountsOut,
        BalancerPool poolAddress
    ) public {
        Position storage position = positionsToUser[msg.sender][
            address(poolAddress)
        ];
        // there are internal checks to handle if the data is consistent in this call
        poolAddress.exitPool(poolAmountIn, minAmountsOut);

        uint256 tokens = poolAddress.getNumTokens();

        for (uint256 i = 0; i < tokens; i++) {
            position.tokens[i] -= minAmountsOut[i];
        }
    }

    function getLockingPeriodLeft(address _pool) public view returns (int256) {
        return
            block.timestamp - positionsToUser[msg.sender][_pool].lockTimestamp;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        // return
        //     _interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES ||
        //     super.supportsInterface(_interfaceId);
    }
}
