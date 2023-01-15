## Dockerfile

1. General format for instructions
   1. INSTRUCTION arguments
2. Comments
   \# comment text
3. FROM
   1. FROM <image_name>
   2. FROM <image_name>:<tag>
4. ENV
   1. define variables
   1. ENV <variable_name> <value>
   2. usage: $variable_name or ${variable_name}
5. ARG
   1. user passed variable
   2. ARG <argument_name>
   3. ARG <argument_name>=<argument_default_value>
6. RUN
   1. shell form: RUN <command_to_excute>
   2. exec form: RUN ["<executable>", "<param1>", "<param2>"]
7. CMD
   1. shell form: CMD <command_to_execute> <param1> <param2>
   2. exec form: CMD ["<executable>", "<param1>", "<param2>"]
   3. As default parameters to "ENTRYPOINT": CMD ["<param1>", "<param2>"]
8. ENTRYPOINT
   1. shell form: ENTRYPOINT <command_to_execute> <param1> <param2>
   2. exec form: ENTRYPOINT ["<executable>", "<param1>", "<param2>"]
9. Lable
   1. LABEL <key1>=<value1> <key1>=<value1> <key1>=<value1>
   2. LABEL <key> <value> (or)
   3. LABEL <key> "<value>"
10. EXPOSE
    1. EXPOSE <port1> <port2>
11. ADD
    1. copy source files to destination
    2. ADD <source>... <destination>
    3. ADD ["<source>",..., "<destination>"]
12. COPY
    1. copy source files to destination
    2. COPY <source>... <destination>
    3. for paths containing white spaces: 
        COPY ["<source>",..., "<destination>"]
13. VOLUME
14. USER
15. WORKDIR
16. ONBUILD
17. STOPSIGNAL
18. HEALTHCHECK
    1. To disable
    2. Options
        1. --interval=DURATION
        2. --timeout=DURATION
        3. --retries=N
19. SHELL
