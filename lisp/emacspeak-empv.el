;;; emacspeak-empv.el --- Speech-enable EMPV  -*- lexical-binding: t; -*-
;;; $Author: tv.raman.tv $
;;; Description:  Speech-enable EMPV An Emacs Interface to empv
;;; Keywords: Emacspeak,  Audio Desktop empv
;;{{{  LCD Archive entry:

;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;;  $Revision: 4532 $ |
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:

;; Copyright (C) 1995 -- 2022, T. V. Raman
;; Copyright (c) 1994, 1995 by Digital Equipment Corporation.
;; All Rights Reserved.
;; 
;; This file is not part of GNU Emacs, but the same permissions apply.
;; 
;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{  introduction

;;; Commentary:
;;; EMPV ==  Another Emacs Media Player
;; Provides better Youtube integration
;;; Code:

;;}}}
;;{{{  Required modules

(eval-when-compile (require 'cl-lib))
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)
(require 'empv nil t)
(require 'iimage nil t)
(declare-function emacspeak-google-canonicalize-result-url
                  "emacspeak-google" (url))
(declare-function emacspeak-google-result-url-prefix "emacspeak-google" nil)

;;}}}
;;{{{Interactive Commands:

(cl-loop
 for f in 
 '(aempv-current-loop-off empv-current-loop-on
                          empv-toggle empv-pause
                          empv-file-loop-off empv-file-loop-on
                          empv-playlist-loop-off empv-playlist-loop-on) do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "speak."
     (when (ems-interactive-p)
       (emacspeak-auditory-icon 'button)))))

(defadvice empv-exit (after emacspeak pre act comp)
  "speak."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'close-object)))

(defadvice empv-youtube-tabulated (after emacspeak pre act comp)
  "speak."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'open-object)
    (emacspeak-speak-mode-line)))

;;}}}
;;{{{Additional Commands:

;;}}}
;;{{{Commands:

(defun emacspeak-empv-play-url (url &optional left-channel)
  "Play URL using mpv;  Prefix arg plays on left channel."
  (interactive (list (emacspeak-eww-read-url) current-prefix-arg ))
  (cl-declare (special tts-notification-device))
  (when
      (and url
           (stringp url)
           (string-prefix-p (emacspeak-google-result-url-prefix) url))
    (setq url  (emacspeak-google-canonicalize-result-url url)))
  (if left-channel
      (with-environment-variables (("PULSE_SINK" tts-notification-device))
        (empv-play url))
      (empv-play url)))

;;}}}
;;{{{Setup:

(defun emacspeak-empv-setup ()
  "Emacspeak setup for empv."
  (cl-declare (special empv-map))
  (global-set-key (ems-kbd "C-; v") empv-map)
  (cl-loop
   for b in
   '(
     ("/" empv-seek)
     ("SPC" empv-toggle)
     ("'" empv-current-loop-on)
     ("RET" empv-youtube-tabulated))
   do
   (emacspeak-keymap-update empv-map b))
  (map-keymap
   (lambda (_key cmd)
     (when (symbolp cmd)
       (put cmd 'repeat-map 'empv-map)))
   empv-map))

(emacspeak-empv-setup)

;;}}}
(provide 'emacspeak-empv)
;;{{{ end of file

;;; local variables:
;;; folded-file: t
;;; end:

;;}}}
