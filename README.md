# 그로킹 딥러닝 실습 환경

책 예제를 셀 단위로 실행·수정해 보는 JupyterLab 환경이다. Python과 라이브러리는 Docker 컨테이너 안에 있고,
노트북 파일은 이 폴더에 그대로 저장된다.

- Python 3.14, JupyterLab, NumPy
- GPU: RTX 4050 연결, CuPy(NumPy와 같은 사용법)

## 처음 받는 PC에서

```bash
git clone https://github.com/en-pantoufles/grokking-dl.git
cd grokking-dl
cp .env.gpu .env               # NVIDIA GPU 가 있는 PC 만 (Windows: copy .env.gpu .env)
```

GPU가 없는 PC(Mac 등)는 `.env` 를 만들지 않는다. 그러면 GPU 없이 CPU로만 뜬다.

## 시작·종료

```bash
docker compose up -d --build   # 시작 (바뀐 것이 없으면 몇 초 안에 끝남)
docker compose down            # 종료
```

## 이어서 공부하기

```bash
git pull                                        # 시작 전: 다른 PC에서 한 것 받기
git add -A && git commit -m "4장 실습" && git push   # 끝난 뒤: 올리기
```

브라우저에서 **http://127.0.0.1:8890/lab** 을 연다. 토큰·비밀번호는 없다(이 PC에서만 접속 가능).

## Jupyter 사용법

노트북(`.ipynb`)은 코드 칸(셀)과 실행 결과를 한 문서에 담은 파일이다. 셀 하나씩 실행하고 결과를 바로 아래에서 본다.

| 하고 싶은 것 | 방법 |
|---|---|
| 셀 실행 후 다음 셀로 | `Shift + Enter` |
| 새 노트북 | File → New → Notebook → Python 3 (ipykernel) |
| 아래에 셀 추가 / 셀 삭제 | `Esc` 누른 뒤 `B` / `D` `D` |
| 저장 | `Ctrl + S` |
| 처음부터 깨끗하게 다시 | Kernel → Restart Kernel and Run All Cells |

변수는 실행한 순서대로 기억된다. 위쪽 셀을 고친 뒤 결과가 이상하면 커널을 재시작하고 처음부터 다시 실행한다.

## 폴더

```text
notebooks/
├── 00_gpu_check.ipynb               # GPU 연결 확인
└── ch03_first_neural_network.ipynb  # 3장 첫 신경망
```

장마다 `notebooks/chNN_주제.ipynb` 로 새 노트북을 만들어 간다.

## GPU

- 책의 코드는 NumPy(CPU)로 동작한다. GPU로 돌려 보려면 `import numpy as np` 를 `import cupy as np` 로 바꾼다.
- 연결 확인: `00_gpu_check.ipynb` 실행, 또는 `docker compose exec jupyter nvidia-smi`

## 패키지 추가

JupyterLab에서 File → New → Terminal 을 열고 `uv add 패키지이름`. 바로 설치되고 `pyproject.toml`·`uv.lock` 에
기록되어 다음 빌드에도 유지된다. 설치 후 노트북은 Kernel → Restart Kernel.

## 문제가 생기면

- 페이지가 안 열린다 → `docker compose logs jupyter`
- 절전 복귀 후 GPU가 안 보인다 → `docker compose up -d --force-recreate`
- 포트 8890이 이미 쓰인다 → `compose.yaml` 의 `127.0.0.1:8890` 앞 숫자를 바꾼다
