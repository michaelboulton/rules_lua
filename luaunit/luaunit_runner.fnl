(let [test_files (os.getenv :TEST_FILES)]
  (if (= nil test_files)
      (error "no test files specified"))
  (each [str (string.gmatch test_files "([^,]+)")]
    (let [trimmed (str:gsub "[.]lua" "")
          replaced (trimmed:gsub "/" ".")
          mod (require replaced)]
      (each [fname f (pairs mod)]
        (if (= (type f) "function")
          (if (fname:match "test.+")
            (if (= nil (. _G fname))
              (tset _G fname f))))))))

(let [luaunit (require :luaunit)]
  (os.exit (luaunit.LuaUnit.run)))
