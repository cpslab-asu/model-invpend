import logging
import pathlib

import matlab
import matlab.engine
import staliro
import staliro.models as models
import staliro.optimizers as optimizers
import staliro.specifications.rtamt as rtamt


class InvPend(models.Model[dict[str, float], None]):
    """A model of an inverted pendulum."""

    def __init__(self, workdir: pathlib.Path):
        self.engine = matlab.engine.start_matlab()
        self.engine.cd(str(workdir))

    def simulate(self, sample: models.Sample) -> models.Result[dict[str, float], None]:
        U = matlab.double([])
        X = matlab.double([sample.static["theta"], sample.static["theta_dot"]])

        states = self.engine.invPend(X, U)
        theta = states[0]
        theta_dot = states[1]
        times = states[2]
        trace = {
            float(t): {"theta": th, "theta_dot": thd} for t, th, thd in zip(times, theta, theta_dot)
        }

        return models.Result(trace, extra=None)


def main():
    workdir = pathlib.Path(__file__).parent

    logging.basicConfig(level=logging.DEBUG)
    logging.info(f"Working directory: {workdir}")

    model = InvPend(workdir)
    spec = rtamt.parse_dense("F (theta <= 0 and theta >= 0)")
    opt = optimizers.UniformRandom()
    opts = staliro.TestOptions(
        runs=1,
        iterations=10,
        static_inputs={
            "theta": (0, 100),
            "theta_dot": (100, 200),
        },
    )

    runs = staliro.test(model, spec, opt, opts)
    print(runs)


if __name__ == "__main__":
    main()
