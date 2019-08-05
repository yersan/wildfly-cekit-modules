configure_protocol_cli_helper() {
  local params=("${@}")
  local stack=${params[0]}
  local protocol=${params[1]}
  local result

  result="
      if (outcome != success) of /subsystem=jgroups/stack=${stack}:read-resource
          /subsystem=jgroups/stack=${stack}:add()
      end-if

      if (outcome == success) of /subsystem=jgroups/stack="${stack}"/protocol="${protocol}":read-resource
          echo \"Cannot configure jgroups '${protocol}' protocol under ${stack} stack. This protocol is already configured.\" >> \${error_file}
          quit
      end-if

      if (outcome != success) of /subsystem=jgroups/stack="${stack}"/protocol="${protocol}":read-resource
          batch"

  # starts in 2, since 0 and 1 are arguments
  for ((j=2; j<${#params[@]}; ++j)); do
    result="${result}
             ${params[j]}"
  done

  result="${result}
          run-batch
      end-if
"
  echo "${result}"
}