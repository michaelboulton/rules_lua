(local example (require :fennel.basic.example))
(local l (require :luaunit))

(lambda test-print []
  "Tests can print"
  (l.assertEquals 2 (example.x 1)))

(lambda test-add-2 []
  "Tests can add 2"
  (l.assertEquals 4 (example.add-2 2)))

{: test-print : test-add-2}
