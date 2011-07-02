{exec} = require 'child_process'

task 'build', 'compile coffee to js, then minify', ->
  exec 'coffee -c coffeetable.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout
    console.log stderr
    exec 'closure --js_output_file coffeetable-min.js --js coffeetable.js', (err, stdout, stderr) ->
      throw err if err
      console.log stdout
      console.log stderr
