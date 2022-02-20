// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Splitwise
 * @dev Manage debt cycles among friends on chain
 */
 
 contract BlockchainSplitwise {
     
    mapping(address => mapping(address => uint32)) public debtors;
    

     function lookup(address debtor, address creditor) public view returns (uint32 ret) {
         ret = debtors[debtor][creditor];
     }
    
     
     function add_IOU(address creditor, uint32 amount, address[] calldata path) public {
         require(creditor != msg.sender, "one person cannot owe money to themself");
         debtors[msg.sender][creditor] += amount;

            
         //path will be passed in optionally if adding this IOU creates a cycle
         //if cycle is A-->B-->C-->A, then array will be that
         if (path.length > 1) {
            // check that passed path is a valid cycle
              bool isValid = valid_path(path);
              require(isValid, "provided path is invalid");
              remove_cycle(path);
             
         }
     }
     
     function valid_path(address[] calldata path) internal view returns (bool){
         for (uint i = 0; i < path.length - 1; i++) {
             if (lookup(path[i], path[i+1])== 0) {
                 return false;
             }
         }
         return true;
     }
     
     function remove_cycle(address[] memory path) internal {
        uint32 smallest_edge = debtors[path[0]][path[1]];
        for (uint i = 1; i < path.length - 1; i++) {
            uint32 edge = debtors[path[i]][path[i+1]];
            if (edge < smallest_edge) {
                smallest_edge = edge;
            }
        }
        for (uint i = 0; i < path.length - 1; i++){
            debtors[path[i]][path[i+1]] -= smallest_edge;
        }
     }
 }