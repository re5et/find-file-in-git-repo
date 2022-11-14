;;; find-file-in-git-repo.el --- Utility to find files in a git repo

;; Copyright 2011 atom smith

;; Author: atom smith
;; URL: http://github.com/re5et/find-file-in-git-repo
;; Version: 0.1.2

;;; Commentary:

;; Using default-directory searches upward for a .git repo directory,
;; then, feeds files into ido-completing-read using git ls-files.

(require 'cl-lib)

;;;###autoload
(defun find-file-in-git-repo ()
  (interactive)
  (let* ((repo (find-git-repo default-directory))
         (local-repo 
          (if (and (fboundp 'tramp-tramp-file-p) (tramp-tramp-file-p repo))
                   (tramp-file-name-localname (tramp-dissect-file-name repo))
            repo))
         (files (shell-command-to-string (format "cd %s && git ls-files" local-repo))))
    (find-file
     (concat repo
             (ido-completing-read
              "find in git repo: "
              (cl-remove-if (lambda (x) (string= "" x))
              (split-string files "\n")))))))

(defun find-git-repo (dir)
  (if (string= "/" dir)
      (message "not in a git repo.")
    (let ((dotgit (expand-file-name ".git" dir)))
      (if (or (file-exists-p (concat dotgit "/"))
              ;; Handle .git files in git worktree directories
              (and (file-readable-p dotgit)
                   (with-temp-buffer (insert-file-contents dotgit)
                                     (looking-at "gitdir: "))))
          dir
        (find-git-repo (expand-file-name "../" dir))))))

;;; find-file-in-git-repo.el ends here

(provide 'find-file-in-git-repo)
