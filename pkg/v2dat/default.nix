{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "v2dat";
  version = "main";
  src = fetchFromGitHub {
    owner = "urlesistiana";
    repo = "v2dat";
    rev = "47b8ee51fb528e11e1a83453b7e767a18d20d1f7";
    hash = "sha256-dJld4hYdfnpphIEJvYsj5VvEF4snLvXZ059HJ2BXwok=";
  };
  vendorHash = "sha256-ndWasQUHt35D528PyGan6JGXh5TthpOhyJI2xBDn0zI=";
}
