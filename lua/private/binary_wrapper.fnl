(local lua_numeric_ver (_VERSION:gsub "Lua " ""))

(lambda read_repo_mapping []
  "Read repo"
  (local repo_mappings {})
  (each [line (io.lines (os.getenv :RUNFILES_REPO_MAPPING))]
    (let [t {}]
      (each [str (line:gmatch "([^,]+)")]
        (table.insert t str))
      (if (= (length t) 2) (table.insert t 1 (. t 2)))
      (table.insert repo_mappings t)))
  repo_mappings)

(lambda is_relevant [repo_name]
  (let [is_lua_dep (repo_name:match "~lua_dependency~")
        is_from_repo_rule (repo_name:match "~_repo_rules~")]
    (or is_lua_dep is_from_repo_rule)))

(lambda read_lua_mappings []
  (local relevant {})
  (each [_ repo_mapping (ipairs (read_repo_mapping))]
    (let [is_relevant (is_relevant (. repo_mapping 1))
          is_lua (string.match (. repo_mapping 2) :lua.+)]
      (if (and is_relevant is_lua)
          (tset relevant (. repo_mapping 2)
                [(. repo_mapping 1) (. repo_mapping 3)]))))
  relevant)

(local _paths_added {})
(set package.path "")
(lambda add_to_path [s]
  "Add item to path"
  (if (= nil (. _paths_added s))
      (do
        (tset _paths_added s true)
        (if (= package.path "")
            (set package.path s)
            (set package.path (.. package.path ";" s))))))

(add_to_path :?.lua)
(add_to_path :?/init.lua)

(local _cpaths_added {})
(set package.cpath "")
(lambda add_to_cpath [s]
  "Add item to cpath"
  (if (= nil (. _cpaths_added s))
      (do
        (tset _cpaths_added s true)
        (if (= package.cpath "")
            (set package.cpath s)
            (set package.cpath (.. package.cpath ";" s))))))

(fn rlocation [workspace_relative ?workspace]
  (let [workspace (or ?workspace :_main)
        runfiles_dir (os.getenv :RUNFILES_DIR)]
    (.. runfiles_dir "/" workspace "/" workspace_relative)))

(tset package.preload :runfiles (fn [] {: rlocation}))

(lambda get_resolved_name [module_name]
  (let [real_module_name (module_name:gsub "[.].+" "")
        with_prefix (.. :lua_ real_module_name)
        relevant (read_lua_mappings)]
    (if (. relevant real_module_name)
        (module_name:gsub real_module_name
                          (-> relevant (. real_module_name) (. 2)))
        (if (. relevant with_prefix)
            (-> relevant (. with_prefix) (. 2))))))

(lambda search_for_module [module_name]
  (-?> (get_resolved_name module_name) require))

(lambda add_runfiles_to_path [runfiles_dir]
  (let [loaders (or package.searchers package.loaders)]
    (table.insert loaders search_for_module))
  (add_to_path (.. runfiles_dir :/?.lua))
  (add_to_path (.. runfiles_dir :/?/init.lua))
  (each [_ v (pairs (read_lua_mappings))]
    (let [root (.. runfiles_dir "/" (. v 2) "/" (. v 2))]
      (add_to_path (.. root :/share/lua/ lua_numeric_ver :/?.lua))
      (add_to_path (.. root :/share/lua/ lua_numeric_ver :/?/init.lua))
      (add_to_cpath (.. root :/lib/lua/ lua_numeric_ver :/?.so)))))

(-?> (os.getenv :RUNFILES_DIR)
     (add_runfiles_to_path))

nil
