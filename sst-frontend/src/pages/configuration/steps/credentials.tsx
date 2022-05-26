import React, { useCallback, useMemo, useState } from "react";
import { Formik } from "formik";
import { useDispatch, useSelector } from "react-redux";
import { useHistory } from "react-router-dom";
import AzureLogo from "/Users/sjia/Aviatrix/sandbox-starter/sst-frontend/src/images/azure.png";
import AWSLogo from "/Users/sjia/Aviatrix/sandbox-starter/sst-frontend/src/images/aws.png";
import GoogleLogo from "/Users/sjia/Aviatrix/sandbox-starter/sst-frontend/src/images/Google.png";
import { addCloudACredentials } from "store/actions/configuration";
import { Input, Button, Heading, Paragraph } from "components/base";
import { FORM_CONFIGS } from "utils/constants";
import { AppState } from "store";
import {
  Box,
  FormControl,
  FormControlLabel,
  FormLabel,
  IconButton,
  Radio,
  RadioGroup,
  TextField,
} from "@material-ui/core";

export default function CloudACredentials() {
  const dispatch = useDispatch();
  const history = useHistory();
  const { step, processedData = {} } = useSelector<
    AppState,
    AppState["configuration"]
  >((state) => state.configuration);
  const {
    credentials_form: { initialValues, validations },
  } = FORM_CONFIGS;
  const onSubmit = useCallback(
    (values) => {
      dispatch(
        addCloudACredentials(
          { 
            cloud_selection: values.cloud_selection,
            key_id: values.access_key_id,
            secret_key: values.secret_access_key,
            azure_application_id: values.azure_application_id,
            azure_application_key: values.azure_application_key,
            azure_directory_id: values.azure_directory_id,
            azure_subscription_id: values.azure_subscription_id,
            gcp_credentials: values.gcp_credentials,
          },
          history
        )

      );
    },
    [history, dispatch]
  );
  const pageDisabled = useMemo(() => step > 1, [step]);
  const { cloudACredentials} = processedData;
  const inputValues: typeof initialValues = cloudACredentials
    ? {
        cloud_selection: cloudACredentials.cloud_selection,
        access_key_id: cloudACredentials.key_id,
        secret_access_key: cloudACredentials.secret_key,
        azure_application_id: cloudACredentials.azure_application_id,
        azure_application_key: cloudACredentials.azure_application_key,
        azure_directory_id: cloudACredentials.azure_directory_id,
        azure_subscription_id: cloudACredentials.azure_subscription_id,
        gcp_credentials: cloudACredentials.gcp_credentials,

      }
    : initialValues;
  return (
    <Formik
      initialValues={{
          cloud_selection: "aws",
          access_key_id: "",
          secret_access_key:"",
          azure_application_id:"",
          azure_application_key:"",
          azure_directory_id:"",
          azure_subscription_id:"",
          gcp_credentials: "",
        }}
      onSubmit={onSubmit}
      validationSchema={validations}
    >
      {({ values, handleChange, handleSubmit, errors }) => (
        <form onSubmit={handleSubmit} className="credential-form-grid">
          <div className="text-block">
            <Heading customClasses="--dark" text="Controller Cloud"></Heading>
            <Paragraph
              customClasses="--light"
              text="Choose a cloud in which the Aviatrix controller and copilot will be deployed"
            ></Paragraph>
          </div>
          <RadioGroup
            row
            name = "cloud_selection"
            value={values.cloud_selection}
            onChange={handleChange}
          >
            <FormControlLabel
              name = "cloud_selection"
              value="aws"
              control={<Radio />}
              label={
                <img
                  src={AWSLogo}
                  className="img-fluid"
                  width="120"
                  height="80"
                />
              }
            />
            <FormControlLabel
              name = "cloud_selection"
              value="gcp"
              control={<Radio />}
              label={
                <img
                  src={GoogleLogo}
                  className="img-fluid"
                  width="120"
                  height="80"
                />
              }
            />
            <FormControlLabel
              name = "cloud_selection"
              value="azure"
              control={<Radio />}
              label={
                <img
                  src={AzureLogo}
                  className="img-fluid"
                  width="140"
                  height="85"
                />
              }
            />
          </RadioGroup>
          {console.log(values.cloud_selection)}
          {(() => {
            if (values.cloud_selection === "aws") {
              return (
                <>
                <Input
                error={Boolean(errors.access_key_id)}
                value={values.access_key_id}
                name="access_key_id"
                label="Access Key ID"
                variant="outlined"
                customClasses="--standard --blue"
                onChange={handleChange}
                helperText={errors.access_key_id}
                disabled={pageDisabled}
              />
              <Input
                value={values.secret_access_key}
                name="secret_access_key"
                label="Secret Access Key"
                variant="outlined"
                customClasses="--standard --blue"
                onChange={handleChange}
                error={Boolean(errors.secret_access_key)}
                helperText={errors.secret_access_key}
                disabled={pageDisabled}
                type="password"
              />
              </>)
            }
          if (values.cloud_selection === "azure"){
            return (
              <>
                <Input
                value={values.azure_subscription_id}
                name="azure_subscription_id"
                label="Subscription ID"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_subscription_id)}
                helperText={errors.azure_subscription_id}
                disabled={pageDisabled}
              />
              <Input
                value={values.azure_directory_id}
                name="azure_directory_id"
                label="Directory (Tenant) ID"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_directory_id)}
                helperText={errors.azure_directory_id}
                disabled={pageDisabled}
              />
              <Input
                value={values.azure_application_id}
                name="azure_application_id"
                label="Application (Client) ID"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_application_id)}
                helperText={errors.azure_application_id}
                disabled={pageDisabled}
                type="password"
              />
              <Input
                value={values.azure_application_key}
                name="azure_application_key"
                label="Application Key (Client Secret)"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_application_key)}
                helperText={errors.azure_application_key}
                disabled={pageDisabled}
                type="password"
              />
            </>)

          }
          if (values.cloud_selection === "gcp"){
            return (
              <Input
              name="gcp_credentials"
              label="GCP Credentials"
              id="gcp_credentials"
            placeholder="Please copy and paste your GCP Credentials"
            multiline
            minRows={10}
            maxRows={20}
            value={values.gcp_credentials}
            variant="outlined"
            onChange={handleChange}
            InputLabelProps={{style: {fontSize: 15}}}
            inputProps={{style: {fontSize: 15}}} 
            disabled={pageDisabled}
            error={Boolean(errors.gcp_credentials)}
            helperText={errors.gcp_credentials}
/>

            )
          }
          })()}
          <span>
            <Button
              type="submit"
              variant="contained"
              customClasses="--blue"
              disabled={pageDisabled}
            >
              Continue
            </Button>
          </span>
        </form>
      )}
    </Formik>
  );
        }