key-RESCUE.clar is a Clarity smart contract for social recovery of accounts on the Stacks blockchain. It enables users to assign trusted guardians who can help recover account ownership if access is lost. The contract supports guardian management, recovery initiation, approval workflow, and secure ownership transfer.

Features
Guardian Management:
Add or remove up to 10 guardians per account.

Recovery Workflow:
Guardians can initiate, approve, and execute recovery requests to transfer account ownership.

Threshold & Delay:
Configurable approval threshold and recovery delay to enhance security.

Error Handling:
Comprehensive checks for duplicate guardians, maximum guardians, pending recoveries, and more.

Contract Functions
Read-only Functions
get-owner(account)
Returns the current owner of an account.

is-guardian(account, guardian)
Checks if a principal is a guardian for an account.

get-guardian-count(account)
Returns the number of guardians for an account.

get-recovery-request(account)
Returns the current recovery request for an account.

count-approvals(account)
Returns the number of guardian approvals for a recovery request (simplified).

Public Functions
add-guardian(guardian)
Adds a guardian for the caller's account.

remove-guardian(guardian)
Removes a guardian from the caller's account.

initiate-recovery(account, new-owner)
Initiates a recovery request for an account.

approve-recovery(account)
Guardian approves a recovery request.

execute-recovery(account)
Executes recovery after threshold and delay.

cancel-recovery()
Cancels a pending recovery request (by owner).

Usage
Add Guardians:
Call add-guardian to assign trusted guardians.

Initiate Recovery:
Guardians can call initiate-recovery if account recovery is needed.

Approve Recovery:
Guardians approve the request via approve-recovery.

Execute Recovery:
Once approvals meet the threshold and delay has passed, call execute-recovery to transfer ownership.

Cancel Recovery:
Owner can cancel a pending recovery with cancel-recovery.


Error Codes
u100: Cannot be own guardian
u101: Already a guardian
u102: Maximum guardians reached
u103: Not a guardian
u104: New owner cannot be the same as account
u105: Recovery already pending
u106: No recovery request
u107: Not a guardian
u108: Recovery already executed
u109: No recovery request
u110: Recovery already executed
u111: Not enough approvals
u112: Delay not passed
u113: Not owner
u114: No pending recovery


Notes
Approval counting is simplified for demonstration; production use should iterate through guardians.
Block numbers are used for delay; adjust as needed for your network.
