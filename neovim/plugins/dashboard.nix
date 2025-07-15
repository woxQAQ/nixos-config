{
  startify = {
    enable = true;

    settings = {
      custom_header = [
        ""
        "     |\     /|(  ___  )|\     /||\     /|\__   __/(       )"
        "     | )   ( || (   ) |( \   / )| )   ( |   ) (   | () () |"
        "     | | _ | || |   | | \ (_) / | |   | |   | |   | || || |"
        "     | |( )| || |   | |  ) _ (  ( (   ) )   | |   | |(_)| |"
        "     | || || || |   | | / ( ) \  \ \_/ /    | |   | |   | |"
        "     | () () || (___) |( /   \ )  \   /  ___) (___| )   ( |"
        "     (_______)(_______)|/     \|   \_/   \_______/|/     \|"
      ];

      change_to_dir = false;
      use_unicode = true;

      lists = [ { type = "dir"; } ];
      files_number = 30;
      autoExpandWidth = true;
      skiplist = [
        "flake.lock"
      ];
    };
  };
}
