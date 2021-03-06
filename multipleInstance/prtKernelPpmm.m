classdef prtKernelPpmm < prtKernel







    
    properties (SetAccess = private)
        name = 'PPMM Kernel'; % RBF Kernel
        nameAbbreviation = 'PPMM'; % RBF
    end
    
    properties
        p = 1; % The inverse kernel width
        trainP = true;
        trainPLims = [0 3];
    end 
    
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,ds)
            self.internalDataSet = ds;
            self.isTrained = true;
            
            
            if self.trainP
                x = ds.data;
                y = ds.targets;
                y = double(y);
                
                y(y == 0) = -1;
                yy = y*y';
                pVals = linspace(self.trainPLims(1)+.01,self.trainPLims(2),100);
                for ind = 1:100
                    gram = prtKernelPpmm.kernelFn(x,x,pVals(ind));
                    %                     gram(gram < 1e-6) = 1e-6;
                    kappa(ind) = trace(gram'*yy);
                    kappa(ind) = kappa(ind)./sqrt(trace(gram'*gram) * trace(yy'*yy));
                end
                [~,ind] = max(kappa);
                self.p = pVals(ind);
            end
        end
        
        function dsOut = runAction(self,ds)
            if ~self.isTrained
                error('prtKernelPpmm:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if self.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelPpmm.kernelFn(ds.getObservations,self.internalDataSet.getObservations,self.p);
                dsOut = ds.setObservations(gram);
            end
        end
    end
    
    methods
        function self = prtKernelPpmm(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.p(self,value)
           
            assert(isnumeric(value) && all(value>0),'p must be a positive numeric scalar')
            self.p = value(:);
        end
    end
    
    methods(Hidden = true)
        function varargout = plot(obj)
        end
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,p)
            
            gram = (x.^p)*((y.^p)');
        end
    end
end
