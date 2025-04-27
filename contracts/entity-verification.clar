;; entity-verification.clar
;; This contract validates business identities

(define-data-var admin principal tx-sender)

;; Entity status: 0 = unverified, 1 = verified, 2 = rejected
(define-map entities
  { entity-id: (string-utf8 36) }
  {
    name: (string-utf8 100),
    jurisdiction: (string-utf8 50),
    status: uint,
    verification-date: uint
  }
)

(define-read-only (get-entity (entity-id (string-utf8 36)))
  (map-get? entities { entity-id: entity-id })
)

(define-public (register-entity
    (entity-id (string-utf8 36))
    (name (string-utf8 100))
    (jurisdiction (string-utf8 50))
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (get-entity entity-id)) (err u100))
    (map-set entities
      { entity-id: entity-id }
      {
        name: name,
        jurisdiction: jurisdiction,
        status: u0,
        verification-date: u0
      }
    )
    (ok true)
  )
)

(define-public (verify-entity (entity-id (string-utf8 36)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (get-entity entity-id)) (err u404))
    (map-set entities
      { entity-id: entity-id }
      (merge (unwrap-panic (get-entity entity-id))
        {
          status: u1,
          verification-date: block-height
        }
      )
    )
    (ok true)
  )
)

(define-public (reject-entity (entity-id (string-utf8 36)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (get-entity entity-id)) (err u404))
    (map-set entities
      { entity-id: entity-id }
      (merge (unwrap-panic (get-entity entity-id))
        {
          status: u2,
          verification-date: block-height
        }
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
