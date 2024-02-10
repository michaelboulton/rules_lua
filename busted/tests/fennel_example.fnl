(local l (require :luaunit))

(fn test-print []
  "Tests can print"
  (l.assertEquals 2 (+ 1 1)))

(lambda test-add-2 []
  "Tests can add 2"
  (l.assertEquals 4 (+ 2 2)))

(lambda test-add-wrong []
  "Tests can add 2"
  (l.assertNotEquals 6 (+ 2 2)))

(lambda test-runfile []
  (let [r (require :runfiles)
        path (r.rlocation :tests/my_example_runfile.txt)]
    (do
      (l.assertNotNil path)
      (each [line (io.lines path)]
        (l.assertEquals line :Hello)))))

{: test-print : test-add-2 : test-add-wrong : test-runfile}
