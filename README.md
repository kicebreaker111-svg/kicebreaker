# KICEBREAKER 배포 안내 (처음 하시는 분용)

구성: **Cloudflare Pages(화면 보여주기) + Supabase(저장소·로그인·이미지)**. 모두 무료 요금제로 시작합니다.
파일: `index.html`(사이트 전체), `supabase.sql`(저장소 규칙), `.github/workflows/keepalive.yml`(멈춤 방지).
※ 각 사이트의 메뉴 이름은 가끔 바뀝니다. 비슷한 이름의 메뉴를 찾으시면 됩니다.

## 0. 준비물
- 관리자로 쓸 **구글 계정**(Gmail) 1개. 이 주소가 관리자 로그인에 쓰입니다.
- **GitHub 계정**, **Cloudflare 계정**, **Supabase 계정**(GitHub 계정으로 가입하면 편합니다).

## 키 주의 (꼭 읽으십시오)
Supabase와 구글 화면에는 비슷해 보이는 키가 여러 개 나옵니다. 아래만 구분하면 됩니다.

| 이름 | 어디에 쓰나 | 공개해도 되나 |
|---|---|---|
| 공개용 키 (publishable 또는 anon) | `index.html`, GitHub Secrets | 괜찮음. 원래 공개되는 값입니다 |
| 비밀 키 (secret 또는 service_role) | 어디에도 쓰지 않음 | **절대 안 됨.** 저장소 규칙을 무시하는 만능 키입니다 |
| 데이터베이스 비밀번호 | 어디에도 쓰지 않음 | **절대 안 됨** |
| 구글 Client Secret | Supabase의 Google 설정 화면에만 | **절대 안 됨.** 파일, GitHub, 대화에 쓰지 마십시오 |

공개용 키가 `index.html`에 보여도 안전한 이유는 `supabase.sql`의 규칙이 서버에서 막아 주기 때문입니다. 그래서 `supabase.sql`을 반드시 먼저 실행하고, Table Editor에서 `docs` 표에 RLS가 켜져 있는지 확인하십시오.

## 1. Supabase 만들기
1. supabase.com > Start your project > 로그인 > New project.
2. 이름은 자유, 데이터베이스 비밀번호는 만들고 따로 적어 두기, Region은 **Northeast Asia (Seoul)**. 무료(Free) 선택 후 생성(1~2분).
3. 왼쪽 **SQL Editor** > New query. `supabase.sql` 내용을 전부 붙여 넣고, 안에 있는 `OWNER_EMAIL`(한 곳)을 관리자 구글 주소로 바꾼 뒤 **Run**. "Success"가 뜨면 됩니다.
4. 왼쪽 **Authentication** > Sign In / Providers에서 **Anonymous sign-ins**를 켜고 저장.
5. 같은 화면에서 **Google**을 켭니다. 아래 2번에서 만든 Client ID와 Client Secret을 여기에 붙여 넣습니다.
6. **Project Settings > API**(또는 Data API)에서 두 가지를 복사해 둡니다: **Project URL**, **공개용 키**(publishable 또는 anon). `secret`/`service_role` 키는 절대 사이트에 넣지 마십시오.

## 2. 구글 로그인 준비(관리자 로그인용)
1. console.cloud.google.com 에서 새 프로젝트 생성.
2. **Google Auth Platform**(또는 APIs & Services > OAuth consent screen) > 시작하기: 앱 이름 `KICEBREAKER`, 지원 이메일은 본인 주소, 대상(Audience)은 **외부(External)**. 게시 상태가 "테스트"이면 **테스트 사용자에 관리자 구글 주소를 추가**하십시오.
3. **Clients**(또는 Credentials) > 클라이언트 만들기 > 유형 **웹 애플리케이션**.
4. **승인된 리디렉션 URI**에 Supabase가 알려주는 주소를 넣습니다. Supabase의 Google 설정 화면에 `https://프로젝트코드.supabase.co/auth/v1/callback` 형태로 적혀 있습니다.
5. 만들어지면 나오는 **Client ID**와 **Client Secret**을 Supabase의 Google 설정에 붙여 넣고 저장.

## 3. index.html 값 바꾸기
메모장 등으로 `index.html`을 열고 맨 위쪽 `window.KICE_CFG`의 세 값을 바꿉니다.
- `url`: Supabase의 Project URL
- `key`: 공개용 키
- `owner`: 관리자 구글 주소(`supabase.sql`에 넣은 것과 **완전히 같게**)

## 4. GitHub에 올리기
1. github.com > New repository. 이름 예: `kicebreaker`. Public이든 Private이든 상관없습니다.
2. 저장소 화면의 **uploading an existing file**을 눌러, 이 폴더의 `index.html`, `supabase.sql`, `README.md`를 올립니다. 숨김 폴더 `.github`는 파일 올리기로 안 올라갈 수 있으니, **Add file > Create new file**에서 이름을 `.github/workflows/keepalive.yml`로 쓰고 내용을 붙여 넣으십시오.
3. Commit changes.

## 5. Cloudflare Pages로 공개
1. dash.cloudflare.com > **Workers & Pages** > Create > **Pages** > **Connect to Git** > GitHub 연결 후 저장소 선택.
2. Framework preset은 **None**, Build command는 **비워 둠**, Build output directory는 **`.`**(점 하나, 저장소 맨 위 폴더). Save and Deploy.
3. 끝나면 `https://이름.pages.dev` 주소가 생깁니다. 이 주소를 **Supabase > Authentication > URL Configuration**의 Site URL과 Redirect URLs에도 넣고 저장하십시오(관리자 로그인에 필요).
4. 이후 수정은 GitHub의 `index.html`을 고치면 자동으로 다시 배포됩니다.
5. 내 도메인을 쓰고 싶으면 Pages 프로젝트의 **Custom domains**에서 연결합니다.

## 6. 멈춤 방지(선택이지만 권장)
Supabase 무료 프로젝트는 일주일 정도 요청이 없으면 멈춥니다. GitHub 저장소 **Settings > Secrets and variables > Actions > New repository secret**에 `SUPABASE_URL`(Project URL), `SUPABASE_KEY`(공개용 키) 두 개를 넣으면 주 2회 자동으로 요청이 갑니다. 저장소에 오래 활동이 없으면 GitHub이 예약 실행을 끌 수 있으니 가끔 Actions 탭을 확인하십시오.

## 7. 점검 목록
- 접속하면 글, 게시판, ABOUT이 보인다.
- 푸터의 **관리자**를 눌러 구글 로그인하면 수정 버튼이 보이고, 로그아웃하면 사라진다.
- 시크릿 창(방문자)에서 댓글, 투표, 반응, 제보가 되고, 다른 사람의 제보는 보이지 않는다.
- 관리자로 이미지를 올리면 보인다. 방문자는 이미지를 올릴 수 없다.

## 8. 기존 사이트 내용 옮기기 (ABOUT, 설정, 자료실, 이미지)
1. Supabase **SQL Editor**에서 `seed.sql` 내용을 붙여 넣고 Run. (반드시 `supabase.sql`을 먼저 실행한 뒤에 합니다.)
2. Supabase **Storage > img** 버킷을 열고 Upload file로 `images` 폴더의 사진을 올립니다. **파일 이름을 바꾸지 말고** 그대로 올려야 합니다.
3. 사이트를 새로고침하면 ABOUT의 예시 문항 이미지까지 보입니다.
기존 댓글, 투표, 닉네임은 방문자마다 번호가 달라져서 옮기지 않습니다.

## 알아 둘 점
- 댓글 제한(1시간에 10개, 1인 300개)과 닉네임 중복 방지는 화면 쪽에서만 막습니다.
- 기존 사이트의 글과 이미지는 자동으로 옮겨지지 않습니다. 글과 설정은 변환해 드릴 수 있고, 이미지는 다시 올려야 합니다.
- 문제가 생기면 브라우저에서 F12 > Console의 빨간 글씨를 복사해 알려 주십시오.
