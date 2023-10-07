// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "elliptic-curve-solidity/contracts/EllipticCurve.sol";

contract ECWeek3 {
    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    uint256 order = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    ECPoint G = ECPoint(1, 2);
    


    function add(ECPoint memory P, ECPoint memory Q) public view returns (ECPoint memory R) {
        (bool success, bytes memory data) = address(0x06).staticcall(abi.encode(P.x, P.y, Q.x, Q.y));

        require(success, "EC addition failed");

        (R.x, R.y) = abi.decode(data, (uint256, uint256));
    }

    function matmul(uint256[] calldata matrix, uint256 n, ECPoint[] calldata s, uint256[] calldata o) public view returns (bool verified) {
        if (matrix.length != n * n || s.length != n || o.length != n) {
            revert("Invalid dimensions");
        }

        for (uint256 i = 0; i < n; i++) {
            ECPoint memory result = ECPoint(0, 0); // Initialize to zero point

            for (uint256 j = 0; j < n; j++) {
                ECPoint memory temp = scalarMul(s[j], matrix[i * n + j]);
                result = add(result, temp);
            }


            if (result.x != o[i]) {
                return false;
            }
        }

        return true;
    }

    function mul(uint256 scalar, uint256 x1, uint256 y1) internal view returns (uint256 x, uint256 y) {
        (bool ok, bytes memory result) = address(7).staticcall(abi.encode(x1, y1, scalar));
        require(ok, "mul failed");
        (x, y) = abi.decode(result, (uint256, uint256));
    }

    

    function scalarMul(ECPoint memory p, uint256 scalar) public view returns (ECPoint memory r) {
        uint256[3] memory input;

        input[0] = p.x;
        input[1] = p.y;
        input[2] = scalar;
        (bool ok, bytes memory result) = address (7).staticcall(abi.encode(input[0], input[1], scalar)); 
        require(ok, "mul failed");
        (r.x, r.y) = abi.decode(result, (uint256, uint256));

        
    }

    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den) public view returns (bool verified) {
    require(den != 0, "Denominator cannot be zero.");
    
    // return true if the prover knows two numbers that add up to num/den
    ECPoint memory LHS = add(A, B);
    uint256 rhs = mulmod(num, EllipticCurve.invMod(den, order), order);
    (uint RHSx, uint RHSy) = mul(rhs, G.x, G.y);
  
    verified = LHS.x == RHSx && LHS.y == RHSy;

    return verified;
  }
}
   
