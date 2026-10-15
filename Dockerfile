FROM python:3.14.6-slim-trixie

COPY --from=ghcr.io/astral-sh/uv:0.11.32 /uv /uvx /usr/local/bin/

# bind mount 한 파일이 호스트 사용자 소유로 남도록 같은 UID/GID 로 실행한다.
# 가상환경도 이 사용자 소유로 두어 JupyterLab 터미널의 `uv add` 가 바로 설치되게 한다.
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} user && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash user && \
    install -d -o ${UID} -g ${GID} /opt/venv /home/user/.cache /home/user/.cache/uv && \
    # JupyterLab 터미널은 로그인 셸이라 /etc/profile 이 PATH 를 초기화한다. venv 를 다시 앞에 둔다.
    echo 'export PATH=/opt/venv/bin:$PATH' > /etc/profile.d/venv.sh
USER user

ENV VIRTUAL_ENV=/opt/venv \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON_DOWNLOADS=never \
    UV_LINK_MODE=copy \
    PATH=/opt/venv/bin:$PATH \
    JUPYTERLAB_SETTINGS_DIR=/work/.jupyter/lab/user-settings \
    JUPYTERLAB_WORKSPACES_DIR=/work/.jupyter/lab/workspaces

# 의존성은 pyproject.toml + uv.lock 으로 고정한다. 프로젝트 폴더는 실행할 때 /work 에 붙는다.
WORKDIR /work
RUN --mount=type=cache,target=/home/user/.cache/uv,uid=${UID},gid=${GID} \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --locked

EXPOSE 8888
# 포트는 127.0.0.1 에만 열고, Host 헤더 검사(allow_remote_access=False)로 DNS rebinding 을 막는다.
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", \
     "--ServerApp.token=", "--ServerApp.allow_remote_access=False", \
     "--ServerApp.root_dir=/work"]
