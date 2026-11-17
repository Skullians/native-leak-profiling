#!/bin/bash

warn() {
    printf "\033[1m\033[33mcontainer@pterodactyl~ \033[1m\033[31m%s\033[0m\n" "$1"
}

warn "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
warn "!!"
warn "!!  THIS GRAALVM IMAGE IS NO LONGER MAINTAINED. IT WILL NEVER GET ANOTHER JAVA UPDATE."
warn "!!"
warn "!!  GraalVM Community stopped publishing JDK updates for this image, so it will"
warn "!!  not get fixes for new Java vulnerabilities like Java4Shell (CVE-2026-114938),"
warn "!!  a remote code execution bug:"
warn "!!  https://www.aikido.dev/blog/java-17-rce-vulnerability-cve-2026-114938"
warn "!!"
warn "!!  Switch your Docker image to a maintained tag by dropping or replacing _graalvm:"
warn "!!    java_21_graalvm       ->  java_21, java_21_zulu or java_21_corretto"
warn "!!    java_perf_21_graalvm  ->  java_perf_21, java_perf_21_zulu or java_perf_21_corretto"
warn "!!"
warn "!!  from your friendly neighbourhood skullians - https://github.com/Skullians/native-leak-profiling"
warn "!!"
warn "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

exec /bin/bash /entrypoint.sh
