require "sweetbread"

task "build", "Compile everything", ()->
  compile "everything", ()->
    rm "public"
    write "public/pauling.js", coffee concat readAll "source/script/**/*.coffee"
    copy "source/index.html", "public/index.html"

task "watch", "Recompile on changes.", ()->
  watch "source", "build", reload

task "serve", "Spin up a live reloading server.", ()->
  serve "public"

task "start", "Build, watch, and serve.", ()->
  invoke "build"
  invoke "watch"
  invoke "serve"
