package com.orient.workshop.owner.service;

import com.orient.workshop.core.model.entity.Branch;
import com.orient.workshop.core.repository.BranchMapper;
import com.orient.workshop.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BranchService {

    private final BranchMapper branchMapper;

    public List<Branch> getAll() {
        return branchMapper.selectList(null);
    }

    @Transactional
    public Branch create(Branch branch) {
        branchMapper.insert(branch);
        return branch;
    }

    @Transactional
    public Branch update(Long id, Branch req) {
        Branch branch = branchMapper.selectById(id);
        if (branch == null) throw new NotFoundException("Branch not found");
        if (req.getName() != null) branch.setName(req.getName());
        if (req.getAddress() != null) branch.setAddress(req.getAddress());
        if (req.getPhone() != null) branch.setPhone(req.getPhone());
        if (req.getEmail() != null) branch.setEmail(req.getEmail());
        if (req.getTimezone() != null) branch.setTimezone(req.getTimezone());
        if (req.getIsActive() != null) branch.setIsActive(req.getIsActive());
        branchMapper.updateById(branch);
        return branch;
    }
}
