;; sanctions-list.clar
;; This contract records restricted parties and jurisdictions

(define-data-var admin principal tx-sender)

;; Sanctioned entity map
(define-map sanctioned-entities
  { entity-id: (string-utf8 36) }
  {
    reason: (string-utf8 100),
    added-at: uint,
    active: bool
  }
)

;; Sanctioned jurisdictions map
(define-map sanctioned-jurisdictions
  { jurisdiction: (string-utf8 50) }
  {
    reason: (string-utf8 100),
    added-at: uint,
    active: bool
  }
)

(define-read-only (is-entity-sanctioned (entity-id (string-utf8 36)))
  (match (map-get? sanctioned-entities { entity-id: entity-id })
    sanction (get active sanction)
    false
  )
)

(define-read-only (is-jurisdiction-sanctioned (jurisdiction (string-utf8 50)))
  (match (map-get? sanctioned-jurisdictions { jurisdiction: jurisdiction })
    sanction (get active sanction)
    false
  )
)

(define-public (add-sanctioned-entity
    (entity-id (string-utf8 36))
    (reason (string-utf8 100))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set sanctioned-entities
      { entity-id: entity-id }
      {
        reason: reason,
        added-at: block-height,
        active: true
      }
    )
    (ok true)
  )
)

(define-public (remove-sanctioned-entity (entity-id (string-utf8 36)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? sanctioned-entities { entity-id: entity-id })) (err u404))
    (map-set sanctioned-entities
      { entity-id: entity-id }
      (merge (unwrap-panic (map-get? sanctioned-entities { entity-id: entity-id }))
        { active: false }
      )
    )
    (ok true)
  )
)

(define-public (add-sanctioned-jurisdiction
    (jurisdiction (string-utf8 50))
    (reason (string-utf8 100))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set sanctioned-jurisdictions
      { jurisdiction: jurisdiction }
      {
        reason: reason,
        added-at: block-height,
        active: true
      }
    )
    (ok true)
  )
)

(define-public (remove-sanctioned-jurisdiction (jurisdiction (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? sanctioned-jurisdictions { jurisdiction: jurisdiction })) (err u404))
    (map-set sanctioned-jurisdictions
      { jurisdiction: jurisdiction }
      (merge (unwrap-panic (map-get? sanctioned-jurisdictions { jurisdiction: jurisdiction }))
        { active: false }
      )
    )
    (ok true)
  )
)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
