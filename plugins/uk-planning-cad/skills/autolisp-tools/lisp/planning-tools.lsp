;;; planning-tools.lsp -- everyday automation for planning drawings
;;; Load with APPLOAD (add to the Startup Suite to load it every time).
;;; Pure AutoLISP, no vla-/vlax- calls, so it also runs in AutoCAD LT 2024+.
;;;
;;; Commands
;;;   TBTAGS    list every attribute tag/value of title blocks on all layouts
;;;   TBSET     set one title block field on every layout (e.g. STATUS = PLANNING)
;;;   TBREV     bump the revision letter and date on every layout
;;;   PLAYERS   create the standard planning layers
;;;   AREAM2    report areas of selected closed shapes in m2, with a total
;;;   BATCHPDF  plot every layout to its own PDF, named from the title block

;;; ---- configuration: edit to match your title block ------------------------

(setq *pt-key-tag* "DWG_NO")   ; a block with this attribute is a title block
(setq *pt-rev-tag* "REV")
(setq *pt-date-tag* "DATE")
(setq *pt-title-tag* "DWG_TITLE")

(setq *pt-layers*
  ;; name            colour linetype     lineweight plot?
  '(("A-WALL-EXST"   8   "Continuous" "0.35" T)
    ("A-WALL-NEWW"   1   "Continuous" "0.50" T)
    ("A-WALL-DEMO"   9   "DASHED"     "0.25" T)
    ("A-WALL-HATCH"  253 "Continuous" "0.05" T)
    ("A-DOOR"        4   "Continuous" "0.25" T)
    ("A-GLAZ"        4   "Continuous" "0.25" T)
    ("A-ROOF"        3   "Continuous" "0.25" T)
    ("A-STAIR"       6   "Continuous" "0.18" T)
    ("A-FURN"        8   "Continuous" "0.13" T)
    ("A-ANNO-TEXT"   7   "Continuous" "0.18" T)
    ("A-ANNO-DIMS"   7   "Continuous" "0.18" T)
    ("A-ANNO-LEVL"   7   "Continuous" "0.18" T)
    ("A-ANNO-REVS"   1   "Continuous" "0.25" T)
    ("A-SITE-BNDY"   7   "DASHED2"    "0.35" T)
    ("A-SITE-REDL"   1   "Continuous" "0.70" T)
    ("A-SITE-BLUL"   5   "Continuous" "0.70" T)
    ("A-SITE-NBRS"   8   "Continuous" "0.18" T)
    ("A-SITE-LAND"   3   "Continuous" "0.13" T)
    ("A-TTLB"        7   "Continuous" "0.25" T)
    ("A-VPRT"        8   "Continuous" "0"    nil)
    ("X-REF"         8   "Continuous" "0.25" T)))

;;; ---- helpers ---------------------------------------------------------------

(defun pt:attribs (blk / e d out)
  ;; ((TAG . attrib-ename) ...) for an INSERT
  (setq e (entnext blk))
  (while (and e (= "ATTRIB" (cdr (assoc 0 (setq d (entget e))))))
    (setq out (cons (cons (strcase (cdr (assoc 2 d))) e) out))
    (setq e (entnext e)))
  (reverse out))

(defun pt:get (blk tag / a)
  (if (setq a (cdr (assoc (strcase tag) (pt:attribs blk))))
    (cdr (assoc 1 (entget a)))))

(defun pt:set (blk tag val / a d)
  (if (setq a (cdr (assoc (strcase tag) (pt:attribs blk))))
    (progn
      (setq d (entget a))
      (entmod (subst (cons 1 val) (assoc 1 d) d))
      (entupd blk)
      T)))

(defun pt:paper-blocks (/ ss i out)
  ;; every attributed block in paper space, on any layout
  (if (setq ss (ssget "_X" '((0 . "INSERT") (66 . 1) (67 . 1))))
    (repeat (setq i (sslength ss))
      (setq out (cons (ssname ss (setq i (1- i))) out))))
  out)

(defun pt:title-blocks (/ out)
  (foreach b (pt:paper-blocks)
    (if (assoc *pt-key-tag* (pt:attribs b)) (setq out (cons b out))))
  out)

(defun pt:layout-of (ent) (cdr (assoc 410 (entget ent))))

(defun pt:today (/ s)
  ;; dd/mm/yyyy from CDATE
  (setq s (rtos (getvar "CDATE") 2 0))
  (strcat (substr s 7 2) "/" (substr s 5 2) "/" (substr s 1 4)))

(defun pt:next-rev (r)
  (cond
    ((or (null r) (= r "") (= r "-") (= r "P")) "A")
    ((and (= (strlen r) 1) (< (ascii (strcase r)) 90))
     (chr (1+ (ascii (strcase r)))))
    (T nil)))

(defun pt:safe-name (s / out c i)
  ;; replace characters Windows does not allow in file names
  (setq out "" i 1)
  (repeat (strlen s)
    (setq c (substr s i 1))
    (setq out (strcat out (if (wcmatch c "[\\/:*?\"<>|]") "-" c)))
    (setq i (1+ i)))
  out)

(defun pt:ltype-file ()
  (cond ((findfile "acadiso.lin")) ((findfile "acadltiso.lin")) (T "acadiso.lin")))

;;; ---- commands --------------------------------------------------------------

(defun c:TBTAGS (/ blks)
  (if (setq blks (pt:paper-blocks))
    (foreach b blks
      (princ (strcat "\n[" (pt:layout-of b) "] block " (cdr (assoc 2 (entget b)))))
      (foreach a (pt:attribs b)
        (princ (strcat "\n    " (car a) " = " (cdr (assoc 1 (entget (cdr a))))))))
    (princ "\nNo attributed blocks found in paper space."))
  (princ))

(defun c:TBSET (/ tag val n)
  (setq tag (strcase (getstring "\nAttribute tag to set (e.g. STATUS): ")))
  (setq val (getstring T (strcat "\nNew value for " tag ": ")))
  (setq n 0)
  (foreach b (pt:title-blocks)
    (if (pt:set b tag val) (setq n (1+ n))))
  (princ (strcat "\n" tag " set to \"" val "\" on " (itoa n) " title block(s)."))
  (princ))

(defun c:TBREV (/ desc old new n)
  (setq desc (getstring T "\nRevision description (for your revision table): "))
  (setq n 0)
  (foreach b (pt:title-blocks)
    (setq old (pt:get b *pt-rev-tag*))
    (if (setq new (pt:next-rev old))
      (progn
        (pt:set b *pt-rev-tag* new)
        (pt:set b *pt-date-tag* (pt:today))
        (setq n (1+ n))
        (princ (strcat "\n[" (pt:layout-of b) "] " (if old old "-") " -> " new)))
      (princ (strcat "\n[" (pt:layout-of b) "] revision \"" old "\" not bumped, set it by hand."))))
  (princ (strcat "\n" (itoa n) " sheet(s) revised. Add the revision table row: \"" desc "\" and cloud the change."))
  (princ))

(defun c:PLAYERS (/ ce name n)
  (setq ce (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (setq n 0)
  (foreach lt '("DASHED" "DASHED2")
    (if (not (tblsearch "LTYPE" lt))
      (command "_.-LINETYPE" "_L" lt (pt:ltype-file) "")))
  (foreach l *pt-layers*
    (setq name (nth 0 l))
    (if (not (tblsearch "LAYER" name)) (setq n (1+ n)))
    (command "_.-LAYER" "_M" name
             "_C" (itoa (nth 1 l)) name
             "_LT" (if (tblsearch "LTYPE" (nth 2 l)) (nth 2 l) "Continuous") name
             "_LW" (nth 3 l) name
             "_P" (if (nth 4 l) "_P" "_N") name
             ""))
  (setvar "CLAYER" "0")
  (setvar "CMDECHO" ce)
  (princ (strcat "\nStandard layers checked, " (itoa n) " created."))
  (princ))

(defun c:AREAM2 (/ ss i e a total ce)
  (if (/= (getvar "INSUNITS") 4)
    (princ "\nWARNING: INSUNITS is not millimetres - areas assume drawing units are mm."))
  (princ "\nSelect closed polylines, circles or regions: ")
  (if (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE,CIRCLE,REGION,ELLIPSE"))))
    (progn
      (setq ce (getvar "CMDECHO") total 0.0)
      (setvar "CMDECHO" 0)
      (repeat (setq i (sslength ss))
        (setq e (ssname ss (setq i (1- i))))
        (command "_.AREA" "_O" e)
        (setq a (/ (getvar "AREA") 1e6) total (+ total a))
        (princ (strcat "\n  " (cdr (assoc 0 (entget e))) " on " (cdr (assoc 8 (entget e)))
                       ": " (rtos a 2 2) " m2")))
      (setvar "CMDECHO" ce)
      (princ (strcat "\nTOTAL: " (rtos total 2 2) " m2 (" (itoa (sslength ss)) " objects)"))))
  (princ))

(defun c:BATCHPDF (/ dir tbs tb name fname n olderr oldvars)
  ;; Uses each layout's own page setup, so set the layouts up for
  ;; "DWG To PDF.pc3" (or your PDF printer) once, then run this.
  (setq oldvars (mapcar '(lambda (v) (cons v (getvar v))) '("FILEDIA" "BACKGROUNDPLOT" "CMDECHO")))
  (setq olderr *error*)
  (defun *error* (msg)
    (foreach v oldvars (setvar (car v) (cdr v)))
    (setq *error* olderr)
    (princ (strcat "\nBATCHPDF stopped: " msg))
    (princ))
  (setvar "FILEDIA" 0)
  (setvar "BACKGROUNDPLOT" 0)
  (setvar "CMDECHO" 0)
  (setq dir (strcat (getvar "DWGPREFIX") "PDF\\"))
  (if (not (vl-file-directory-p dir)) (vl-mkdir dir))
  (if (not (vl-file-directory-p dir)) (setq dir (getvar "DWGPREFIX")))
  (setq tbs (pt:title-blocks) n 0)
  (foreach lay (layoutlist)
    (setq tb nil)
    (foreach b tbs (if (= (strcase (pt:layout-of b)) (strcase lay)) (setq tb b)))
    (setq name
      (if (and tb (pt:get tb *pt-key-tag*))
        (strcat (pt:get tb *pt-key-tag*)
                (if (pt:get tb *pt-rev-tag*) (strcat "-" (pt:get tb *pt-rev-tag*)) "")
                (if (pt:get tb *pt-title-tag*) (strcat " " (pt:get tb *pt-title-tag*)) ""))
        lay))
    (setq fname (strcat dir (pt:safe-name name) ".pdf"))
    (if (findfile fname) (vl-file-delete fname))
    (command "_.-PLOT" "_N" lay "" "" fname "_N" "_Y")
    (if (findfile fname)
      (progn (setq n (1+ n)) (princ (strcat "\n  " fname)))
      (princ (strcat "\n  FAILED: " lay " (check its page setup uses a PDF device)"))))
  (foreach v oldvars (setvar (car v) (cdr v)))
  (setq *error* olderr)
  (princ (strcat "\n" (itoa n) " PDF(s) written to " dir))
  (princ))

(princ "\nPlanning tools loaded: TBTAGS TBSET TBREV PLAYERS AREAM2 BATCHPDF")
(princ)
