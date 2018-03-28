#lang racket
(require file/glob)

;; Parse arguments
(define input-path null)
(define output-path null)

(command-line
 #:once-each
 [("-i" "--input") input "Input path" (set! input-path input)]
 [("-o" "--output") output "Output path" (set! output-path output)])

;; Ensure directory paths end in slashes
(unless (string-suffix? input-path "/")
  (set! input-path (string-append input-path "/")))
(unless (string-suffix? output-path "/")
  (set! output-path (string-append output-path "/")))

;; Main part of script
(define mp3s (glob (string-append input-path "**.mp3")))
(define output-filename null)
(map (lambda (i)
       (define artist (path->string (list-ref (explode-path i) 4)))
       (define album (path->string (list-ref (explode-path i) 5)))
       (define mp3 (path->string (file-name-from-path i)))
       (define result (with-output-to-string (lambda () (system (format "ffprobe -v error -show_entries format=duration \"~a\"" i)))))
       (define mp3-length (first (regexp-match #px"\\d+.\\d+" result)))
       (set! mp3-length (ceiling (string->number mp3-length)))
       (if (equal? artist "Various Artists")
           (set! output-filename (string-append "VA_" album "_" mp3))
           (set! output-filename (string-append artist "_" album "_" mp3)))
       (set! output-filename (string-replace output-filename " " "_"))
       (set! output-filename (string-replace output-filename "mp3" "png"))
       (set! output-filename (string-append output-path output-filename))
       (system (format "audiowaveform -i \"~a\" -o ~a -e ~a -w 1600 -h 500" i output-filename mp3-length))) mp3s)
