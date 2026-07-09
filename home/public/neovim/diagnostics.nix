{
  diagnostic.settings = {
    underline = false;

    severity_sort = true;
    # NOTE: Opt-in with 0.11
    virtual_text = {
      severity.min = "warn";
      source = "if_many";
    };
    virtual_lines = false;

    float = {
      border = "rounded";
    };
  };
}
