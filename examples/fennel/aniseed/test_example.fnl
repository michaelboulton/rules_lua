(module test_example
  {autoload {example :fennel.aniseed.example}})

(local l (require :std))

(local inspect (require :inspect))
(local lfs (require :lfs))

(print lfs)
(print (inspect lfs))

(deftest test-add-2
  (t.= 0 (example.add-2 -2))
  (t.= 2 (example.add-2 0))
  (t.= 9 (example.add-2 7))
  (t.= 4 (example.add-2 2)))

(deftest test-add-4
  (t.= 6 (example.x 2)))
