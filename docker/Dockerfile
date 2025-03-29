FROM metabase/metabase:v0.46.6

# Run as non-root user (security best practice)
RUN adduser --disabled-password --gecos '' metabase && \
    chown -R metabase /metabase-data
USER metabase


HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1


EXPOSE 3000
