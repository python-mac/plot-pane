# from https://pypi.org/project/imgcat/

from os import path

import io
import base64
import subprocess

from matplotlib._pylab_helpers import Gcf
from matplotlib.figure import Figure
from matplotlib.backend_bases import (
     FigureCanvasBase, FigureManagerBase, GraphicsContextBase, RendererBase)


class FigureManagerMultitab(FigureManagerBase):

    viewer = path.join(path.dirname(__file__), 'Plot Pane.app')

    def show(self):
        canvas = self.canvas

        fig = canvas.figure
        if fig.canvas is None:
            from matplotlib.backends.backend_agg import FigureCanvasAgg
            FigureCanvasAgg(fig)

        with io.BytesIO() as buf:
            fig.savefig(buf)
            b64 = base64.encodebytes(buf.getvalue()).decode()

            subprocess.run(['open', "plot-pane:" + b64 , '-a', self.viewer])


def show(block=None):
    for manager in Gcf.get_all_fig_managers():
        manager.show()

        # Do not re-display what is already shown.
        Gcf.destroy(manager.num)


def new_figure_manager(num, *args, **kwargs):
    FigureClass = kwargs.pop('FigureClass', Figure)
    fig = FigureClass(*args, **kwargs)
    return new_figure_manager_given_figure(num, fig)


def new_figure_manager_given_figure(num, figure):
    # this must be lazy-loaded to avoid unwanted configuration of mpl backend
    from matplotlib.backends.backend_agg import FigureCanvasAgg

    canvas = FigureCanvasAgg(figure)
    manager = FigureManagerMultitab(canvas, num)
    return manager
