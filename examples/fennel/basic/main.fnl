(local example (require :fennel.basic.example))
(local runfiles (require :runfiles))

(print (example.add-2 2))

(with-open [f (assert (io.open (runfiles.rlocation :fennel/basic/data.txt)))]
  (print (f:read :*l)))
