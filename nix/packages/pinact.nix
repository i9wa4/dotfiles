{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pinact";
  version = "3.7.3";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "pinact";
    rev = "v${version}";
    hash = "sha256-CL9umWOFpAvTDzAHW/LSlaY19wJBodXlC0VmpAc5kOo=";
  };

  vendorHash = "sha256-jECv3szHWAW1zOlhimBcTgK2twPetJFY0ro+KjKoZik=";

  meta = {
    description = "Pin GitHub Actions versions";
    homepage = "https://github.com/suzuki-shunsuke/pinact";
  };
}
