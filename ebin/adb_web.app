{application, adb_web,
[{description, "The angra-db web application."},
 {vsn, "0.01"},
 {modules, [adb_web_app, adb_web_sup, adb_web_server]},
 {registered, [adb_web_sup]},
 {applications, [kernel, stdlib, lager]},
 {mod, {adb_web_app, []}}
]}.
