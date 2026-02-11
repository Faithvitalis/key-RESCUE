;; Social Recovery Contract

;; Data Variables
(define-data-var recovery-threshold uint u3)
(define-data-var recovery-delay uint u144) ;; ~24 hours in blocks

;; Data Maps
(define-map account-owner principal principal)
(define-map guardians 
  { account: principal, guardian: principal } 
  { active: bool, added-at: uint }
)
(define-map guardian-count principal uint)

(define-map recovery-requests
  principal
  {
    new-owner: principal,
    initiated-at: uint,
    executed: bool
  }
)

(define-map recovery-approvals
  { account: principal, guardian: principal }
  bool
)

;; Read-only functions
(define-read-only (get-owner (account principal))
  (default-to account (map-get? account-owner account))
)

(define-read-only (is-guardian (account principal) (guardian principal))
  (default-to false 
    (get active (map-get? guardians { account: account, guardian: guardian }))
  )
)

(define-read-only (get-guardian-count (account principal))
  (default-to u0 (map-get? guardian-count account))
)

(define-read-only (get-recovery-request (account principal))
  (map-get? recovery-requests account)
)

(define-read-only (count-approvals (account principal))
  (let
    (
      (request (unwrap! (map-get? recovery-requests account) u0))
    )
    ;; In production, iterate through guardians to count approvals
    u0 ;; Simplified
  )
)

;; Public functions

;; Add a guardian
(define-public (add-guardian (guardian principal))
  (let
    (
      (caller tx-sender)
      (current-count (get-guardian-count caller))
    )
    (asserts! (not (is-eq caller guardian)) (err u100)) ;; Can't be own guardian
    (asserts! (not (is-guardian caller guardian)) (err u101)) ;; Already guardian
    (asserts! (< current-count u10) (err u102)) ;; Max 10 guardians
    
    (map-set guardians
      { account: caller, guardian: guardian }
      { active: true, added-at: u0 }
    )
    (map-set guardian-count caller (+ current-count u1))
    (ok true)
  )
)

;; Remove a guardian
(define-public (remove-guardian (guardian principal))
  (let
    (
      (caller tx-sender)
      (current-count (get-guardian-count caller))
    )
    (asserts! (is-guardian caller guardian) (err u103)) ;; Not a guardian
    
    (map-set guardians
      { account: caller, guardian: guardian }
      { active: false, added-at: u0 }
    )
    (map-set guardian-count caller (- current-count u1))
    (ok true)
  )
)

;; Initiate recovery
(define-public (initiate-recovery (account principal) (new-owner principal))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (not (is-eq account new-owner)) (err u104))
    (asserts! (is-none (map-get? recovery-requests account)) (err u105)) ;; Recovery already pending
    
    (map-set recovery-requests account
      {
        new-owner: new-owner,
        initiated-at: u0,
        executed: false
      }
    )
    (ok true)
  )
)

;; Guardian approves recovery
(define-public (approve-recovery (account principal))
  (let
    (
      (caller tx-sender)
      (request (unwrap! (map-get? recovery-requests account) (err u106)))
    )
    (asserts! (is-guardian account caller) (err u107)) ;; Not a guardian
    (asserts! (not (get executed request)) (err u108)) ;; Already executed
    
    (map-set recovery-approvals
      { account: account, guardian: caller }
      true
    )
    (ok true)
  )
)

;; Execute recovery (after threshold met and delay passed)
(define-public (execute-recovery (account principal))
  (let
    (
      (request (unwrap! (map-get? recovery-requests account) (err u109)))
      (approvals (count-approvals account))
      (threshold (var-get recovery-threshold))
      (delay (var-get recovery-delay))
    )
    (asserts! (not (get executed request)) (err u110))
    (asserts! (>= approvals threshold) (err u111)) ;; Not enough approvals
    (asserts! (>= u1 (+ (get initiated-at request) delay)) (err u112)) ;; Delay not passed
    
    ;; Transfer ownership
    (map-set account-owner account (get new-owner request))
    
    ;; Mark as executed
    (map-set recovery-requests account
      (merge request { executed: true })
    )
    
    (ok true)
  )
)

;; Cancel recovery (by current owner)
(define-public (cancel-recovery)
  (let
    (
      (caller tx-sender)
      (owner (get-owner caller))
    )
    (asserts! (is-eq caller owner) (err u113)) ;; Not owner
    (asserts! (is-some (map-get? recovery-requests caller)) (err u114)) ;; No pending recovery
    
    (map-delete recovery-requests caller)
    (ok true)
  )
)