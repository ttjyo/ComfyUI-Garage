FROM huchukato/comfyui-qwenvl-runpod@sha256:92f7b86bf356f49829eba6e354dc6cebd3910ab7329d950d2194d64e7588667e
COPY --chmod=755 october-setup.sh /usr/local/bin/october-setup.sh
COPY --chmod=755 october-entrypoint.sh /usr/local/bin/october-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/october-entrypoint.sh"]
