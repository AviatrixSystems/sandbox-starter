import React, { useCallback } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useHistory } from "react-router-dom";

import { Button, Heading } from "components/base";
import Logo from "../../images/logo.png";
import { deleteConfig } from "store/actions";
import { helpIcon, reloadIcon } from "svgs";
import { AppState } from "store";

export default function AppBar() {
  const version = "1.3.0";
  const dispatch = useDispatch();
  const history = useHistory();
  const { is_advance } = useSelector<AppState, AppState["configuration"]>(
    (state) => state.configuration
  );

  const onDelete = useCallback(() => {
    const response = window.confirm("Are you sure you want to destroy?");
    if (response) {
      dispatch(deleteConfig(history));
    }
  }, [dispatch, history]);

  return (
    <header className="app-header">
      <img className="app-logo__logo" src={Logo} alt="Aviatrix logo" />
      <div className="app-logo__divider" />
      <Heading text="Sandbox Starter" customClasses="--title" />
      <div className="sst_ver__divider" />
      <Heading text={version} customClasses="--inverse" />
      <Heading
        text={is_advance ? "Advanced Mode" : "Standard Mode"}
        customClasses="--inverse --mode"
      />
      <div className="vertical-separator" />
      <a className="mailto" href="mailto:sandbox-starter@aviatrix.com">
        {helpIcon}
      </a>
      <Button
        title="Terraform Destroy"
        variant="contained"
        customClasses="--primary-inverse"
        onClick={onDelete}
        startIcon={reloadIcon}
      >
        Destroy
      </Button>
    </header>
  );
}
