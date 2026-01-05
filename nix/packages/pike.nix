{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pike";
  version = "0.3.87";

  src = fetchFromGitHub {
    owner = "jameswoolfenden";
    repo = "pike";
    rev = "v${version}";
    hash = "sha256-D0LC77H2eFMmCb4Tn95H5Hc5SKu8pR/Aa/kZF3FqijY=";
  };

  vendorHash = "sha256-kql+0oqpl9O2zz3lXKhsqGcFRG5CVYX0/62WqNP9M8Y=";

  # Tests require Terraform installation
  doCheck = false;

  meta = {
    description = "Generate IAM policies from Terraform/CloudFormation";
    homepage = "https://github.com/jameswoolfenden/pike";
  };
}
