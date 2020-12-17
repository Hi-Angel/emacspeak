;;; emacspeak-extras.el --- Speech-enable EXTRAS  -*- lexical-binding: t; -*-
;;; $Author: tv.raman.tv $
;;; Description:  Speech-enable EXTRAS An Emacs Interface to extras
;;; Keywords: Emacspeak,  Audio Desktop extras
;;{{{  LCD Archive entry:

;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;; $Date: 2007-05-03 18:13:44 -0700 (Thu, 03 May 2007) $ |
;;;  $Revision: 4532 $ |
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:
;;;Copyright (C) 1995 -- 2007, 2019, T. V. Raman
;;; All Rights Reserved.
;;;
;;; This file is not part of GNU Emacs, but the same permissions apply.
;;;
;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNEXTRAS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{  introduction

;;; Commentary:
;;; Infrequently used wizards archived for posterity.

;;; Code:

;;}}}
;;{{{  Required modules

(require 'cl-lib)
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)

;;}}}
;;{{{ Keymaps <-> Org (text) Files :

;;; This makes it easy to consolidate personal bindings across machines.
;;; It also protects against custom losing settings due to Custom accidents.
;;;

(defun emacspeak-wizards-bindings-from-org (variable filename)
  "Load bindings from a specified file."
  (interactive "vVariable: \nfFilename: ")
  (let ((bindings nil))
    (with-temp-buffer
      "org-to-map"
      (insert-file-contents filename)
      (goto-char (point-min))
      (while (not (eobp))
        (let ((fields
               (split-string
                (buffer-substring-no-properties
                 (line-beginning-position) (line-end-position))
                " " 'omit-nulls)))
          (push
           (list (cl-first fields) (intern (cl-second fields)))
           bindings))
        (forward-line 1)))
    (setq bindings (nreverse (copy-sequence bindings)))
    (set variable  bindings)
    (customize-save-variable variable bindings)))

(defun emacspeak-wizards-bindings-to-org (variable filename)
  "Persists mapping to org file."
  (interactive "vVariable: \nfFilename: ")
  (let ((buffer (find-file-noselect  filename)))
    (with-current-buffer
        buffer
      (goto-char (point-max))
      (cl-loop
       for binding  in (symbol-value variable) do
       (insert (format "%s %s\n" (cl-first binding) (cl-second binding))))
      (save-buffer buffer))
    (switch-to-buffer buffer)))

;;}}}
;;{{{Midi Playback Using MuseScore ==mscore:


(defvar emacspeak-wizards-media-pipe
  (expand-file-name "pipe.flac" emacspeak-user-directory)
  "Named socket for piped media streams.")

;;;###autoload
(defun emacspeak-wizards-midi-using-m-score (midi-file)
  "Play midi file using mscore from musescore package."
  (interactive "fMidi File:")
  (cl-declare (special emacspeak-wizards-media-pipe))
  (cl-assert (executable-find "mscore") t "Install mscore first")
  (or (file-exists-p emacspeak-wizards-media-pipe)
      (shell-command (format "mknod %s p"
                             emacspeak-wizards-media-pipe)))
  (cl-assert (file-exists-p emacspeak-wizards-media-pipe) t
             "Error creating named socket")
  (emacspeak-m-player emacspeak-wizards-media-pipe)
  (message "converting %s to audio" midi-file)
  (shell-command
   (format "%s -o %s %s &"
           (executable-find "mscore")
           emacspeak-wizards-media-pipe midi-file)))

;;}}}
;;{{{ Braille

;;;###autoload
(defun emacspeak-wizards-braille (s)
  "Insert Braille string at point."
  (interactive "sBraille: ")
  (require 'toy-braille)
  (insert (get-toy-braille-string s))
  (emacspeak-auditory-icon 'yank-object)
  (message "Brailled %s" s))

;;}}}
;;{{{ Add autoload cookies:

(defvar emacspeak-autoload-cookie-pattern
  ";;;###autoload"
  "autoload cookie pattern.")


(defun emacspeak-wizards-add-autoload-cookies (&optional f)
  "Add autoload cookies to file f.
Default is to add autoload cookies to current file."
  (interactive)
  (cl-declare (special emacspeak-autoload-cookie-pattern))
  (or f (setq f (buffer-file-name)))
  (let ((buffer (find-file-noselect f))
        (count 0))
    (with-current-buffer buffer
      (goto-char (point-min))
      (unless (eq major-mode 'emacs-lisp-mode)
        (error "Not an Emacs Lisp file."))
      (condition-case nil
          (while (not (eobp))
            (re-search-forward "^ *(interactive")
            (beginning-of-defun)
            (forward-line -1)
            (unless (looking-at emacspeak-autoload-cookie-pattern)
              (cl-incf count)
              (forward-line 1)
              (beginning-of-line)
              (insert
               (format "%s\n" emacspeak-autoload-cookie-pattern)))
            (end-of-defun))
        (error "Added %d autoload cookies." count)))))

;;}}}
;;{{{ voice sample


(defsubst voice-setup-read-personality (&optional prompt)
  "Read name of a pre-defined personality using completion."
  (read (completing-read (or prompt "Personality: ")
                         (tts-list-voices))))

(defun emacspeak-wizards-voice-sampler (personality)
  "Read a personality  and apply it to the current line."
  (interactive (list (voice-setup-read-personality)))
  (put-text-property (line-beginning-position) (line-end-position)
                     'personality personality)
  (emacspeak-speak-line))


(defun emacspeak-wizards-generate-voice-sampler (step)
  "Generate a buffer that shows a sample line in all the ACSS settings
for the current voice family."
  (interactive "nStep:")
  (let ((buffer (get-buffer-create "*Voice Sampler*"))
        (voice nil))
    (save-current-buffer
      (set-buffer buffer)
      (erase-buffer)
      (cl-loop
       for a from 0 to 9 by step do
       (cl-loop
        for p from 0 to 9 by step do
        (cl-loop
         for s from 0 to 9 by step do
         (cl-loop
          for r from 0 to 9 by step do
          (setq voice (voice-setup-personality-from-style
                       (list nil a p s r)))
          (insert
           (format
            " Aural CSS average-pitch %s pitch-range %s stress %s richness %s"
            a p s r))
          (put-text-property (line-beginning-position)
                             (line-end-position)
                             'personality voice)
          (end-of-line)
          (insert "\n"))))))
    (switch-to-buffer buffer)
    (goto-char (point-min))))

(defun voice-setup-defined-voices ()
  "Return list of voices defined via defvoice."
  (let ((result nil))
    (mapatoms
     #'(lambda (s)
         (when  
             (and
              (string-match "^voice-"  (symbol-name s))
              (boundp s)
              (symbolp (symbol-value s))
              (string-match  "^acss-" (symbol-name  (symbol-value s))))
           (push s result))))
    result))




(defun emacspeak-wizards-show-defined-voices ()
  "Display a buffer with sample text in the defined voices."
  (interactive)
  (let ((buffer (get-buffer-create "*Voice Sampler*"))
        (voices
         (sort
          (voice-setup-defined-voices)
          #'(lambda (a b)
              (string-lessp (symbol-name a) (symbol-name b))))))
    (save-current-buffer
      (set-buffer buffer)
      (erase-buffer)
      (cl-loop
       for v in voices do
       (insert
        (format "This is a sample of voice %s. " (symbol-name v)))
       (put-text-property
        (line-beginning-position) (line-end-position)
        'personality v)
       (end-of-line)
       (insert "\n")))
    (funcall-interactively #'switch-to-buffer buffer)
    (goto-char (point-min))))

;;}}}
;;{{{ list-voices-display

(defvar ems--wizards-sampler-text
  "Emacspeak --- The Complete Audio Desktop!"
  "Sample text used  when displaying available voices.")

(defun emacspeak-wizards-list-voices (pattern)
  "Show all defined voice-face mappings  in a help buffer.
Sample text to use comes from variable
  `ems--wizards-sampler-text "
  (interactive (list (and current-prefix-arg
                          (read-string "List faces matching regexp: "))))
  (cl-declare (special ems--wizards-sampler-text))
  (let ((list-faces-sample-text ems--wizards-sampler-text))
    (list-faces-display pattern)
    (message "Displayed voice-face mappings in other window.")))


(defun voice-setup-show-rogue-faces ()
  "Return list of voices that map to non-existent faces."
  (cl-declare (special voice-setup-face-voice-table))
  (cl-loop for f being the hash-keys of voice-setup-face-voice-table
           unless (facep f) collect f))
;;}}}
;;{{{ tramp wizard
(defcustom emacspeak-wizards-tramp-locations nil
  "Tramp locations used by Emacspeak tramp wizard.
Locations added here via custom can be opened using command
emacspeak-wizards-tramp-open-location
bound to \\[emacspeak-wizards-tramp-open-location]."
  :type '(repeat
          (cons :tag "Tramp"
                (string :tag "Name")
                (string :tag "Location")))
  :group 'emacspeak-wizards)


(defun emacspeak-wizards-tramp-open-location (name)
  "Open specified tramp location.
Location is specified by name."
  (interactive
   (list
    (let ((completion-ignore-case t))
      (completing-read "Location:"
                       emacspeak-wizards-tramp-locations
                       nil 'must-match))))
  (cl-declare (special emacspeak-wizards-tramp-locations))
  (let ((location (cdr (assoc name
                              emacspeak-wizards-tramp-locations))))
    (find-file
     (read-file-name "Open: " location))))

;;}}}
(provide 'emacspeak-extras)
;;{{{ end of file

;;; local variables:
;;; folded-file: t
;;; end:

;;}}}
