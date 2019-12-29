using System;

namespace PackageUpdate {
    /// <summary>
    /// 
    /// </summary>
    public class ModuleRule {
        /// <summary>
        /// Id as an Identifier for a rule
        /// </summary>
        public int Id;

        /// <summary>
        /// ModuleNames to exclude from update checking
        /// </summary>
        public string[] ExcludeModuleFromChecking;

        /// <summary>
        /// ModuleNames to include from update checking
        /// </summary>
        public string[] IncludeModuleForChecking;

        /// <summary>
        /// Report when major version changed for a module
        /// </summary>
        public bool ReportChangeOnMajor;

        /// <summary>
        /// Report when minor version changed for a module
        /// </summary>
        public bool ReportChangeOnMinor;

        /// <summary>
        /// Report when build version changed for a module
        /// </summary>
        public bool ReportChangeOnBuild;

        /// <summary>
        /// Report when revision part changed for a module
        /// </summary>
        public bool ReportChangeOnRevision;
    }
}
