import React, { useCallback, useMemo } from "react";
import { Formik } from "formik";
import { useDispatch, useSelector } from "react-redux";
import { useHistory } from "react-router-dom";

import { addAWSCredentials } from "store/actions/configuration";
import { Input, Button, Heading, Paragraph } from "components/base";
import { FORM_CONFIGS } from "utils/constants";
import { AppState } from "store";

export default function Credentials() {
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
        addAWSCredentials(
          {
            key_id: values.access_key_id,
            secret_key: values.secret_access_key,
          },
          history
        )
      );
    },
    [history, dispatch]
  );
  const pageDisabled = useMemo(() => step > 1, [step]);
  const { awsConfigurations } = processedData;
  const inputValues: typeof initialValues = awsConfigurations
    ? {
      access_key_id: awsConfigurations.key_id,
      secret_access_key: awsConfigurations.secret_key,
    }
    : initialValues;

  return (
    <Formik
      initialValues={inputValues}
      onSubmit={onSubmit}
      validationSchema={validations}
    >
      {({ values, handleChange, handleSubmit, errors }) => (
        <form onSubmit={handleSubmit} className="credential-form-grid">
          <div className="text-block">
            <Heading customClasses="--dark" text="AWS Credentials"></Heading>
            <Paragraph
              customClasses="--light"
              text="Going to get your AWS API access keys. They are required to launch the Aviatrix controller in AWS. They stay local to this container and are not shared. Access keys can be created in AWS console under Account -> My Security Credentials -> Access keys for CLI, SDK, & API access."
            ></Paragraph>
          </div>
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
