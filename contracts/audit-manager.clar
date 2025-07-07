;; Audit Manager Verification Contract
;; Manages audit manager permissions and verification

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_MANAGER (err u101))
(define-constant ERR_NOT_MANAGER (err u102))

;; Data maps
(define-map audit-managers principal bool)
(define-map manager-details principal {
    name: (string-ascii 50),
    certification: (string-ascii 100),
    registered-at: uint
})

;; Read-only functions
(define-read-only (is-audit-manager (manager principal))
    (default-to false (map-get? audit-managers manager))
)

(define-read-only (get-manager-details (manager principal))
    (map-get? manager-details manager)
)

;; Public functions
(define-public (register-audit-manager (manager principal) (name (string-ascii 50)) (certification (string-ascii 100)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-audit-manager manager)) ERR_ALREADY_MANAGER)
        (map-set audit-managers manager true)
        (map-set manager-details manager {
            name: name,
            certification: certification,
            registered-at: block-height
        })
        (ok true)
    )
)

(define-public (revoke-audit-manager (manager principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-audit-manager manager) ERR_NOT_MANAGER)
        (map-delete audit-managers manager)
        (map-delete manager-details manager)
        (ok true)
    )
)
