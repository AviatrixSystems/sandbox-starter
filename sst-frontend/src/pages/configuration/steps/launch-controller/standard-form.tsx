import React, { Dispatch, useCallback } from "react";
import { Formik } from "formik";

import { Input, Button, Heading, Paragraph } from "components/base";
import { FORM_CONFIGS } from "utils/constants";
import { launchController } from "store/actions/configuration";
import { ConfigurationState } from "types/store";
import { FormControl, InputLabel, MenuItem, Select } from "@material-ui/core";

interface ComponentProps {
  processedData: ConfigurationState["processedData"];
  pageDisabled: boolean;
  history: any;
  dispatch: Dispatch<any>;
}

const {
  launch_controller: { initialValues, validations },
} = FORM_CONFIGS;

export default function StandardForm(props: ComponentProps) {
  const { processedData = {}, pageDisabled, dispatch, history } = props;
  const onSubmit = useCallback(
    (values) => {
      dispatch(
        launchController(
          {
            email: values.email,
            recovery_email: values.email,
            password: values.password,
            confirm_password: values.confirm_password,
            controller_version: values.controller_version,
            controller_license_type: values.controller_license_type,
            controller_license: values.controller_license,
          },
          history
        )
      );
    },
    [dispatch, history]
  );
  const { controller } = processedData;
  const inputValues: typeof initialValues = controller
    ? {
      email: controller.email,
      password: controller.password,
      confirm_password: controller.confirm_password,
      controller_version: controller.controller_version,
      controller_license_type: controller.controller_license_type,
      controller_license: controller.controller_license,
    }
    : initialValues;
  return (
    <Formik
      initialValues={{
        email: "",
        password: "",
        confirm_password: "",
        controller_version: "7.0",
        controller_license_type: "byol",
        controller_license: "",
      }}
      onSubmit={onSubmit}
      validationSchema={validations}
      validate={(values) => {
        const errors: { confirm_password?: string } = {};
        if (
          values.password &&
          values.confirm_password &&
          values.password !== values.confirm_password
        ) {
          errors.confirm_password = "Password is not same";
        }
        return errors;
      }}
    >
      {({ values, handleChange, handleSubmit, errors }) => (
        <form onSubmit={handleSubmit} className="launch-controller-grid">
          <div className="text-block">
            <Heading
              customClasses="--dark"
              text="Launch Controller"
            ></Heading>
            <Paragraph
              customClasses="--light"
              text={
                <span>
                  Enter email for controller password recovery and for Aviatrix
                  support to reach out in case of issues (the email will be
                  shared with Aviatrix)
                </span>
              }
            ></Paragraph>
          </div>
          <Input
            value={values.email}
            name="email"
            label="Email Address"
            variant="outlined"
            fullWidth={false}
            customClasses="--small --blue"
            onChange={handleChange}
            error={Boolean(errors.email)}
            helperText={errors.email}
            disabled={pageDisabled}
          />
          <Input
            type="password"
            value={values.password}
            name="password"
            label="Password"
            variant="outlined"
            fullWidth={false}
            customClasses="--small --blue"
            onChange={handleChange}
            error={Boolean(errors.password)}
            helperText={errors.password}
            disabled={pageDisabled}
          />
          <Input
            type="password"
            value={values.confirm_password}
            name="confirm_password"
            label="Re-enter Password"
            fullWidth={false}
            variant="outlined"
            customClasses="--small --blue"
            onChange={handleChange}
            error={Boolean(errors.confirm_password)}
            helperText={errors.confirm_password}
            disabled={pageDisabled}
          />
          <FormControl variant="outlined" size="medium" style={{ width: 360 }}>
            <InputLabel
              style={{
                fontSize: 14,
              }}
              variant="outlined"
              htmlFor="controller_version"
            >
              Controller Version
            </InputLabel>
            <Select
              labelId="controller_version"
              name="controller_version"
              value={values.controller_version}
              onChange={handleChange}
              label="Controller Version"
              variant="outlined"
              style={{
                color: "black",
                fontSize: 14,
              }}
              disabled={pageDisabled}
            >
              <MenuItem value="6.9">6.9</MenuItem>
              <MenuItem value="7.0">7.0</MenuItem>
            </Select>
          </FormControl>
          {(() => {
            if (values.controller_version === "6.9") {
              return (
                <>
                  <Paragraph
                    customClasses="--light"
                    text={
                      <span>
                        If using the SST as a prerequisite to ACE Automation (IaC), please select Controller Version 7.0
                      </span>
                    }
                  ></Paragraph>
                </>
              );
            }
          })()}
          <>
            <Input
              value={values.controller_license}
              name="controller_license"
              label="Controller License"
              variant="outlined"
              fullWidth={false}
              customClasses="--small --blue"
              onChange={handleChange}
              error={Boolean(errors.controller_license)}
              helperText={errors.controller_license}
              disabled={pageDisabled}
            />
            <Paragraph
              customClasses="--light"
              text={
                <span>
                  Before clicking 'Continue' below, subscribe to{" "}
                  <a
                    target="blank"
                    href="https://aws.amazon.com/marketplace/pp/prodview-qzvzwigqw72ek"
                  >
                    Aviatrix Secure Networking Platform Metered 2208-Universal 24x7 Support
                  </a>{" "}
                  ,{" "}
                  <a
                    target="blank"
                    href="https://aws.amazon.com/marketplace/pp/prodview-nsys2ingy6m3w"
                  >
                    Aviatrix Secure Networking Platform - BYOL
                  </a>{" "}
                  , and{" "}
                  <a
                    target="blank"
                    href="https://aws.amazon.com/marketplace/pp/prodview-hr74smekrfqiu"
                  >
                    Aviatrix CoPilot
                  </a>{" "}
                  in the AWS Marketplace. For "Metered 2208", click on "Continue to subscribe", then
                  "Subscribe", and "Set Up Your Account" to generate your Controller License.
                  For "BYOL", click on "Continue to subscribe", then "Subscribe".
                  For CoPilot, click "Continue to subscribe", but do NOT click on
                  "Continue to Configuration".
                </span>
              }
            ></Paragraph>
          </>
          <span>
            <Button
              disabled={pageDisabled}
              type="submit"
              variant="contained"
              customClasses=" --blue"
            >
              Continue
            </Button>
          </span>
        </form>
      )}
    </Formik>
  );
}
