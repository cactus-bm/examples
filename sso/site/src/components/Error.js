import Dialog from "@mui/material/Dialog";
import DialogContent from "@mui/material/DialogContent";
import DialogTitle from "@mui/material/DialogTitle";
import DialogActions from "@mui/material/DialogActions";
import Button from "@mui/material/Button";
import { Alert, Grid } from "@mui/material";

const Error = ({ title, description, buttons }) => {
  return (
    <Dialog
      open={true}
      aria-labelledby={"error-dialog-title"}
      maxWidth={"lg"}
      fullWidth
      scroll={"paper"}
      className={"error-dialog"}
    >
      <DialogTitle id={"error-dialog-title"}>{title || "Error"}</DialogTitle>
      <DialogContent>
        <Grid container spacing={2}>
          <Grid item xs={12}>
            <Alert severity="error">
              {description || "An error has occured"}
            </Alert>
          </Grid>
        </Grid>
      </DialogContent>
      {buttons && (
        <DialogActions
          sx={{
            justifyContent: "space-between",
            padding: "0 24px 18px 24px",
          }}
        >
          <Grid container spacing={2}>
            <Grid
              item
              container
              spacing={2}
              direction={"row"}
              xs={12}
              justifyContent="flex-end"
            >
              {buttons.map((button, index) => (
                <Grid item xs={"auto"} key={index}>
                  <Button
                    disableElevation
                    variant={button.variant}
                    color={button.color}
                    onClick={button.onClick}
                  >
                    {button.label}
                  </Button>
                </Grid>
              ))}
            </Grid>
          </Grid>
        </DialogActions>
      )}
    </Dialog>
  );
};

export default Error;
