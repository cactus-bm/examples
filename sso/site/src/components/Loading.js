import { RotatingLines } from "react-loader-spinner";

const Loading = () => (
    <div style={{
        display: "inline-block",
        position: "fixed",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
    }}><RotatingLines
            color={"grey"}
            strokeWidth="5"
            animationDuration="275"
            ariaLabel="rotating-lines-loading"
            height={96}
            width={96}
        /></div>
);

export default Loading;