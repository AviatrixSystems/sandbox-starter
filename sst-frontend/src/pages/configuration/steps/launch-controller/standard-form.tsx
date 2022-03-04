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
        controller_license_type: "meteredplatinum",
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
              text="Launch Controller and Copilot"
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
              htmlFor="controller_license_type"
            >
              Controller License Type
            </InputLabel>
            <Select
              labelId="controller_license_type"
              name="controller_license_type"
              value={values.controller_license_type}
              onChange={handleChange}
              label="Controller License Type"
              variant="outlined"
              style={{
                color: "black",
                fontSize: 14,
              }}
              disabled={pageDisabled}
            >
              <MenuItem value="meteredplatinum">Metered Platinum</MenuItem>
              <MenuItem value="byol">BYOL</MenuItem>
            </Select>
          </FormControl>
          {(() => {
            if (values.controller_license_type === "byol") {
              return (
                <>
                  <Input
                    value={values.controller_license}
                    name="controller_license"
                    label="Controller License"
                    variant="outlined"
                    fullWidth={false}
                    customClasses="--small --blue"
                    onChange={handleChange}
                    error
                    helperText="Required"
                    disabled={pageDisabled}
                  />
                  <Paragraph
                    customClasses="--light"
                    text={
                      <span>
                        Subscribe to the{" "}
                        <a
                          target="blank"
                          href="https://aws.amazon.com/marketplace/pp/prodview-nsys2ingy6m3w"
                        >
                          Aviatrix BYOL Platform
                        </a>{" "}
                        on AWS Marketplace. Click on "Continue to subscribe",
                        and accept the terms. Do NOT click on "Continue to
                        Configuration".
                      </span>
                    }
                  ></Paragraph>
                </>
              );
            } else {
              return (
                <Paragraph
                  customClasses="--light"
                  text={
                    <span>
                      Subscribe to the{" "}
                      <a
                        target="blank"
                        href="https://aws.amazon.com/marketplace/pp/B08NTSDHKG"
                      >
                        Aviatrix Metered Platform
                      </a>{" "}
                      on AWS Marketplace. Click on "Continue to subscribe", and
                      accept the terms. Do NOT click on "Continue to
                      Configuration".
                    </span>
                  }
                ></Paragraph>
              );
            }
          })()}
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
