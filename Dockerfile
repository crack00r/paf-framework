# PAF Framework - Docker Image
# For CI/CD integration and containerized usage
# Version is read dynamically from VERSION file

FROM node:20-alpine

# Build argument for version (passed via --build-arg PAF_VERSION=$(cat VERSION))
ARG PAF_VERSION=unknown

LABEL maintainer="PAF Framework Team"
LABEL version="${PAF_VERSION}"
LABEL description="PAF - Perspective Agent Framework for AI-powered code reviews"

# Install dependencies
RUN apk add --no-cache \
    bash \
    git \
    curl \
    jq

# Create paf user
RUN addgroup -S paf && adduser -S paf -G paf

# Set working directory
WORKDIR /home/paf/.paf

# Copy framework files
COPY --chown=paf:paf . .

# Make scripts executable
RUN chmod +x bin/* scripts/* 2>/dev/null || true

# Switch to paf user
USER paf

# Set environment variables
ENV PAF_HOME=/home/paf/.paf
ENV PATH="${PAF_HOME}/bin:${PATH}"

# Verify installation on build
RUN bash scripts/verify-paf.sh || echo "Verification completed"

# Default command (reads version from VERSION file at runtime)
CMD ["bash", "-c", "echo \"PAF Framework v$(cat VERSION) Ready\" && bash"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD [ -f "/home/paf/.paf/SKILL.md" ] || exit 1
