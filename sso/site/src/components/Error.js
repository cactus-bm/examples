import Dialog from "@mui/material/Dialog";
import DialogContent from "@mui/material/DialogContent";
import DialogTitle from "@mui/material/DialogTitle";
import { Alert, Grid } from "@mui/material";

const Error = ({ title, description }) => {
    return <Dialog
        open={true}
        aria-labelledby={"error-dialog-title"}
        maxWidth={"lg"}
        fullWidth
        scroll={"paper"}
        className={"error-dialog"}
    >
        <DialogTitle id={"error-dialog-title"}>
            {title || "Error"}
        </DialogTitle>
        <DialogContent dividers={true}>
            <Grid container spacing={2}>
                <Grid item xs={12} >
                    <Alert severity="error">
                        {description || "An error has occured"}
                    </Alert>
                </Grid>
            </Grid>

        </DialogContent>
    </Dialog>
};

export default Error;