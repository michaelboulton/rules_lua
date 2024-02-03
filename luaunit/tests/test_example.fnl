(local l (require :luaunit))

(lambda test-print []
  "Tests can print"
  (l.assertEquals 2 (+ 1 1)))

(lambda test-add-2 []
  "Tests can add 2"
  (l.assertEquals 4 (+ 2 2)))

{: test-print : test-add-2}
