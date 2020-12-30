;;;; yeodl-cl.lisp

(in-package #:yeodl)

(defparameter *yeodl-db* nil)

;; data structures

(defstruct instrument
  ticker
  opens
  highs
  lows
  closes
  volumes
  adjusted-closes
  (indicators '()) )

;; DATE functions

(defun get-current-date-str ()
  (multiple-value-bind
	(ss mm hh dd mon yy dow dst-p tz)
      (get-decoded-time)
    (format nil "~d-~2,'0d-~2,'0d"
	    yy
	    mon
	    dd)))

(defun get-date-bars-ago (num-days
			  &optional (as-of-date (get-current-date-str)))
  (execute-one-row-m-v
   *yeodl-db*
   (concatenate 'string
		"with dates (d) as"	     
			  " (select distinct fdate as d from prices "
			  "  where fdate <= ? "
			  "  order by fdate desc "
			  "  limit ? )"
			  "select min(d) from dates")
   as-of-date num-days))


(defun get-dates-by-num-days (num-days
			      &optional (as-of-date (get-current-date-str)))
  (iter (for (date)
	     in-sqlite-query
	     (concatenate 'string
			  "with dates (d) as"	     
			  " (select distinct fdate as d from prices "
			  "  where fdate <= ? "
			  "  order by fdate desc "
			  "  limit ? )"
			  "select d from dates order by d asc")
	     on-database *yeodl-db*
	     with-parameters (as-of-date num-days))
    (collect date result-type vector)))


(defun get-dates-by-start-date (start-date)
  (iter (for (date)
	     in-sqlite-query
	     "select distinct fdate from prices where fdate>=? order by fdate asc"
	     on-database *yeodl-db*
	     with-parameters (start-date))
    (collect date result-type vector)))
	     
;; FILE functions

(defun file-get-contents (filename)
  (with-open-file (stream filename)
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      contents)))

;; ARRAY helper function

(defun read-array (str)
            (values (read-from-string
                     (concatenate 'string "#("
                                  str
                                  ")"))))

;; YEODL DB queries

(defun get-tickers-from-file (sql-filename)
  (let ((sql (file-get-contents sql-filename)))
    (iter (for (ticker)
	       in-sqlite-query sql
	       on-database *yeodl-db*)
      (collect ticker))))


(defun get-instrument (ticker start-date)
  (multiple-value-bind (ticker2 opens highs lows closes volumes adjusted-closes)
      (execute-one-row-m-v
       *yeodl-db*
       (concatenate 'string
		    " select distinct symbol,"
		    "  group_concat(open, ' ')"
		    "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
		    "         as opens,"
		    "  group_concat(high, ' ')"
		    "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
		    "         as highs,"
		    "  group_concat(low, ' ')"
		    "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
		    "         as lows,"
		    "  group_concat(close, ' ')"
		    "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
		    "         as closes,"
		    "  group_concat(volume,' ')"
		    "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
		    "         as volumes,"
		    "  group_concat(adjusted_close,' ')"
		    "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
		    "         as adj_closes"
		    " from prices where symbol = ?  and fdate >= ?")
       ticker start-date)
    (make-instrument :ticker ticker
		     :opens (read-array opens)
		     :highs (read-array highs)
		     :lows (read-array lows)
		     :closes (read-array closes)
		     :volumes (read-array volumes)
		     :adjusted-closes (read-array adjusted-closes)
		     :indicators '())))

  


(defun get-instruments-from-tickers (tickers start-date)
  (iter (for (ticker opens highs lows closes volumes adjusted-closes)
	     in-sqlite-query
	     (concatenate 'string
			  " select distinct symbol,"
			  "  group_concat(open, ' ')"
			  "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
			  "         as opens,"
			  "  group_concat(high, ' ')"
			  "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
			  "         as highs,"
			  "  group_concat(low, ' ')"
			  "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
			  "         as lows,"
			  "  group_concat(close, ' ')"
			  "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
			  "         as closes,"
			  "  group_concat(volume,' ')"
			  "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
			  "         as volumes,"
			  "  group_concat(adjusted_close,' ')"
			  "   over (partition by symbol order by fdate rows between unbounded preceding and unbounded following)"
			  "         as adj_closes"
			  " from prices where fdate >= ?"
			  " and symbol in ("
			  (format nil "~{'~a'~^, ~}" tickers)
			  ")")
	     on-database *yeodl-db*
	     with-parameters (start-date))
    (collect (make-instrument :ticker ticker
			      :opens           (read-array opens)
			      :highs           (read-array highs)
			      :lows            (read-array lows)
			      :closes          (read-array closes)
			      :volumes         (read-array volumes)
			      :adjusted-closes (read-array adjusted-closes)))))


  





			   
			   
