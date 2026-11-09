{ pkgs, ... }: {
  programs = {

    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-notify # notifications
        gh-eco # explore the ecosystem
        gh-cal # contributions calender terminal viewer
        gh-poi # clean up local branches safely
        gh-stack # stacked pull requests

        gh-markdown-preview
      ];
      settings.prompt = "enabled";
    };

    gh-dash = {
      enable = true;
      settings = {
        prSections = [
          {
            title = "Needs my review";
            filters = "is:open review-requested:@me";
          }
          {
            title = "My PRs";
            filters = "is:open author:@me";
          }
          {
            title = "Involved";
            filters = "is:open involves:@me -author:@me";
          }
          {
            title = "Stale";
            filters = "is:open involves:@me updated:<{{ nowModify \"-14d\" }}";
          }
        ];
      };
    };
  };
}
